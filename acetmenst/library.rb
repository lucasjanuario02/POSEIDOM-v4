# frozen_string_literal: true

require 'set'
require 'weakref'
require 'traceback'
require 'torch'

module Torch
  module Library
    @impls = Set.new
    @defs = Set.new
    @reserved_namespaces = ['prim']

    class QpyError < StandardError; end

    class Library
      attr_reader :ns, :kind, :dispatch_key

      def initialize(ns, kind, dispatch_key = "")
        unless %w[IMPL DEF FRAGMENT].include?(kind)
          raise ValueError, "Unsupported kind: #{kind}"
        end

        if @reserved_namespaces.include?(ns) && (kind == "DEF" || kind == 'FRAGMENT')
          raise ValueError, "#{ns} is a reserved namespace. Please try creating a library with another name."
        end

        frame = Traceback.extract(3)[0]
        filename, lineno = frame.filename, frame.lineno

        @m = Torch::Dispatch.library(kind, ns, dispatch_key, filename, lineno)
        @ns = ns
        @op_defs = Set.new
        @op_impls = Set.new
        @registration_handles = []
        @kind = kind
        @dispatch_key = dispatch_key

        ObjectSpace.define_finalizer(self, self.class.finalize(@impls, @op_impls, @defs, @op_defs, @registration_handles))
      end

      def self.finalize(impls, op_impls, defs, op_defs, registration_handles)
        proc {
          impls.subtract(op_impls)
          defs.subtract(op_defs)
          registration_handles.each(&:destroy)
        }
      end

      def define(schema, alias_analysis = "", tags: [])
        raise RuntimeError, "Invalid alias_analysis type #{alias_analysis}" unless ["", "FROM_SCHEMA", "CONSERVATIVE"].include?(alias_analysis)

        name = schema.split("(")[0]
        packet_name = name.split(".")[0] || name
        has_preexisting_packet = Torch::Ops.const_defined?(@ns) && Torch::Ops.const_get(@ns).const_defined?(packet_name)

        result = @m.define(schema, alias_analysis, tags)
        name = schema.split("(")[0]
        qualname = "#{@ns}::#{name}"

        if has_preexisting_packet
          ns = Torch::Ops.const_get(@ns)
          packet = ns.const_get(packet_name)
          Torch::Ops.refresh_packet(packet)
        end

        @op_defs.add(qualname)
        @defs.add(qualname)
        result
      end

      def impl(op_name, fn, dispatch_key = '', with_keyset: false)
        raise TypeError, "Input function is required to be a callable but found type #{fn.class}" unless fn.respond_to?(:call)
        dispatch_key = @dispatch_key if dispatch_key.empty?

        name = op_name.is_a?(String) ? op_name : op_name._schema.name
        key = "#{@ns}/#{name.split("::")[-1]}/#{dispatch_key}"
        raise RuntimeError, "This is not allowed since there's already a kernel registered from python overriding #{name.split("::")[-1]}'s behavior for #{dispatch_key} dispatch key and #{@ns} namespace." if @impls.include?(key)

        if dispatch_key == "Meta"
          dispatcher_op_name = name.include?('::') ? name : "#{@ns}::#{name}"
          if Torch::Dispatch.has_kernel_for_dispatch_key?(dispatcher_op_name, "CompositeImplicitAutograd")
            raise RuntimeError, "We should not register a meta kernel directly to the operator '#{name}', because it has a CompositeImplicitAutograd kernel in core. Instead we should let the operator decompose, and ensure that we have meta kernels for the base ops that it decomposes into."
          end
        end

        @m.impl(name, dispatch_key == "" ? "CompositeImplicitAutograd" : dispatch_key, fn, with_keyset)
        @impls.add(key)
        @op_impls.add(key)
      end

      def _destroy
        @m.reset if @m
        @m = nil
        @registration_handles.each(&:destroy)
        @registration_handles.clear
        @impls.subtract(@op_impls)
        @op_defs.each do |name|
          ns, name_with_overload = name.split("::")
          name = name_with_overload.split(".")[0]
          next unless Torch::Ops.const_defined?(ns)
          namespace = Torch::Ops.const_get(ns)
          next unless namespace.const_defined?(name)
          namespace.remove_const(name)
        end
      end
    end

    def self.define(qualname, schema, lib: nil, tags: [])
      raise ValueError, "define(qualname, schema): expected qualname to be instance of str, got #{qualname.class}" unless qualname.is_a?(String)
      namespace, name = Torch::Utils.parse_namespace(qualname)
      lib ||= Library.new(namespace, "FRAGMENT")
      @keep_alive << lib
      raise ValueError, "define(qualname, schema, ...): expected schema to look like e.g. \"(Tensor x) -> Tensor\" but got \"#{schema}\"" unless schema.match?(/\(.*\) -> .*/)
      lib.define(name + schema, "", tags: tags)
    end

    def self.impl(qualname, types, func = nil, lib: nil)
      keys = Set.new
      types = [types] if types.is_a?(String)
      types.each do |typ|
        is_dispatch_key = Torch::Dispatch.parse_dispatch_key?(typ)
        keys.add(is_dispatch_key ? typ : device_type_to_key(typ))
      end

      register = proc do |func|
        namespace, _ = Torch::Utils.parse_namespace(qualname)
        use_lib = lib || Library.new(namespace, "FRAGMENT")
        @keep_alive << use_lib if lib.nil?
        keys.each { |key| use_lib.impl(qualname, func, key) }
      end

      func ? register.call(func) : register
    end

    def self.device_type_to_key(device_type)
      device_type == "default" ? "CompositeExplicitAutograd" : Torch::Dispatch.key_for_device(device_type)
    end

    def self.get_ctx
      Torch::AbstractImpl.global_ctx_getter
    end

    @keep_alive = []
  end
end

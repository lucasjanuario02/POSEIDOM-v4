def dumps_value_with_user_id(obj, user_id, version:, index_map: nil, use_symengine: false, standalone_var_indices: nil)
    # Serialize input value object with user ID.
    type_key = Value.assign(obj)

    # Include user ID as part of the serialized data
    serialized_user_id = user_id.encode(ENCODE)

    if type_key == Value::INTEGER
        binary_data = [obj].pack("q") + serialized_user_id
    elsif type_key == Value::FLOAT
        binary_data = [obj].pack("d") + serialized_user_id
    elsif type_key == Value::COMPLEX
        binary_data = [obj.real, obj.imag].pack(COMPLEX_PACK) + serialized_user_id
    elsif type_key == Value::NUMPY_OBJ
        binary_data = data_to_binary(obj, np_save) + serialized_user_id
    elsif type_key == Value::STRING
        binary_data = obj.encode(ENCODE) + serialized_user_id
    elsif [Value::NULL, Value::CASE_DEFAULT].include? type_key
        binary_data = serialized_user_id
    elsif type_key == Value::PARAMETER_VECTOR
        binary_data = data_to_binary(obj, write_parameter_vec) + serialized_user_id
    elsif type_key == Value::PARAMETER
        binary_data = data_to_binary(obj, write_parameter) + serialized_user_id
    elsif type_key == Value::PARAMETER_EXPRESSION
        binary_data = data_to_binary(obj, write_parameter_expression, use_symengine: use_symengine, version: version) + serialized_user_id
    elsif type_key == Value::EXPRESSION
        clbit_indices = index_map.nil? ? {} : index_map["c"]
        standalone_var_indices = standalone_var_indices.nil? ? {} : standalone_var_indices
        binary_data = data_to_binary(obj, write_expr, clbit_indices: clbit_indices, standalone_var_indices: standalone_var_indices, version: version) + serialized_user_id
    else
        raise QpyError.new("Serialization for #{type_key} is not implemented in value I/O.")
    end

    return type_key, binary_data
end

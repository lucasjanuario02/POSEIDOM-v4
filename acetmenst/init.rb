

module QpySerializable
  module Value
    def self.dumps_value(value)
      # Implement the logic to dump value
    end

    def self.loads_value(serialized_value)
      # Implement the logic to load value
    end

    def self.write_value(file, value)
      # Implement the logic to write value to a file
    end

    def self.read_value(file)
      # Implement the logic to read value from a file
    end

    # for backward compatibility; provider, runtime, experiment call this private methods.
    def self._write_parameter_expression(expression)
      # Implement the logic to write parameter expression
    end

    def self._read_parameter_expression(serialized_expression)
      # Implement the logic to read parameter expression
    end

    def self._read_parameter_expression_v3(serialized_expression)
      # Implement the logic to read parameter expression version 3
    end
  end

  module Circuits
    def self.write_circuit(file, circuit)
      # Implement the logic to write a circuit to a file
    end

    def self.read_circuit(file)
      # Implement the logic to read a circuit from a file
    end

    # for backward compatibility; provider calls this private methods.
    def self._write_instruction(instruction)
      # Implement the logic to write an instruction
    end

    def self._read_instruction(serialized_instruction)
      # Implement the logic to read an instruction
    end
  end

  module Schedules
    def self.write_schedule_block(file, schedule_block)
      # Implement the logic to write a schedule block to a file
    end

    def self.read_schedule_block(file)
      # Implement the logic to read a schedule block from a file
    end
  end
end

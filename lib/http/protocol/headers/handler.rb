module HTTP
  module Protocol
    class Headers
      class Handler
        def self.header_name
          @header_name ||=
            begin
              str = name.split("::").last
              str.gsub! %r{(?:[a-z])(?:[A-Z])} do |camelized_str|
                dasherized_str = ""
                dasherized_str << camelized_str[0]
                dasherized_str << "-"
                dasherized_str << camelized_str[1]
                dasherized_str
              end
              str
            end
        end

        attr_reader :value

        dependency :logger, Telemetry::Logger

        def self.build(*arguments)
          instance = new *arguments
          Telemetry::Logger.configure instance
          instance
        end

        def assign(value)
          logger.trace "Assigning value (Input Value: #{value.inspect}, Header Name: #{header_name.inspect})"
          value = coerce value if value.is_a? String
          Array(value).each &method(:validate)
          @value = value
          logger.debug "Value assigned (Coerced Value: #{value.inspect}, Header Name: #{header_name.inspect})"
        end

        def coerce(str)
          str
        end

        def copy
          other_instance = dup
          instance_variables.each do |ivar|
            value = instance_variable_get ivar
            value = value.dup if value.is_a? Enumerable
            other_instance.instance_variable_set ivar, value
          end
          other_instance
        end

        def header_name
          self.class.header_name
        end

        def validate(*)
        end

        def serialized_value
          value.to_s
        end

        def to_s
          "#{header_name}: #{serialized_value}\r\n"
        end

        class CustomHeader < Handler
          attr_reader :header_name

          def initialize(header_name)
            @header_name = header_name
          end
        end
      end
    end
  end
end

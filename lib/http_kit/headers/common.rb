require_relative "define_header"
require_relative "handler"

module HTTPKit
  class Headers
    class Common < Headers
      extend DefineHeader

      define_header "Connection" do
        CONNECTIONS = %w(close keep-alive)

        def validate value
          unless CONNECTIONS.include? value
            raise ArgumentError, "bad Connection value #{value.inspect}; valid values are #{CONNECTIONS.map(&:inspect) * ", "}"
          end
        end
      end

      define_header "Content-Length" do
        def validate value
          if value < 0
            raise ArgumentError, "content length must not be negative"
          end
        end

        def coerce str
          str.to_i
        end

        def to_i
          value
        end
      end

      define_header "Content-Type"

      define_header "Date" do
        def coerce str
          Time.parse str
        end

        def value
          @value.httpdate
        end
      end
    end
  end
end

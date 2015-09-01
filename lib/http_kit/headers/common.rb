require_relative "define_header"
require_relative "handler"

module HTTPKit
  class Headers
    class Common < Headers
      extend DefineHeader

      define_header "Connection" do
        CONNECTIONS = %w(close keep-alive)

        def assign value
          unless CONNECTIONS.include? value
            raise ArgumentError, "bad Connection value #{value.inspect}; valid values are #{CONNECTIONS.map(&:inspect) * ", "}"
          end
          @connection = value
        end
        alias_method :connection=, :assign

        def value
          @connection
        end
      end

      define_header "Content-Length" do
        def assign value
          num = Integer(value)
          if num < 0
            raise ArgumentError, "content length must not be negative"
          end
          @content_length = num
        end
        alias_method :content_length=, :assign

        def value
          @content_length
        end
      end

      define_header "Content-Type" do
        def assign value
          @content_type = value
        end

        def value
          @content_type
        end
      end

      define_header "Date" do
        def assign raw
          date = coerce raw
          @date = date.httpdate
        end
        alias_method :date=, :assign

        def coerce value
          if value.is_a? Time
            value
          else
            Time.parse value
          end
        end

        def value
          @date
        end
      end
    end
  end
end

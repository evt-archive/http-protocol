require_relative "define_header"
require_relative "handler"

module HTTPKit
  class Headers
    class Common < Headers
      extend DefineHeader

      define_header "Connection" do
        CONNECTIONS = %w(close keep-alive)

        def connection= value
          unless CONNECTIONS.include? value
            raise ArgumentError, "bad Connection value #{value.inspect}; valid values are #{CONNECTIONS.map(&:inspect) * ", "}"
          end
          @connection = value
        end

        def value
          @connection
        end
      end

      define_header "Content-Length" do
        def content_length= value
          num = Integer(value)
          if num < 0
            raise ArgumentError, "content length must not be negative"
          end
          @content_length = num
        end

        def value
          @content_length
        end
      end

      define_header "Date" do
        def date= date
          @date = date.httpdate
        end

        def value
          @date
        end
      end
    end
  end
end

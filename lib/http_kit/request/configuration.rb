require_relative "configuration/expose"

module HTTPKit
  class Request
    module Configuration
      class Accept
        attr_reader :content_types

        def initialize
          @content_types = []
        end

        def accept! content_type
          unless content_type.match %r{\A.+/.+\Z}
            raise ArgumentError, "invalid content type #{content_type.inspect}"
          end
          content_types << content_type.to_s
        end

        alias_method :accepted_content_types, :content_types
      end

      class AcceptCharset
        attr_reader :accepted_charsets

        def initialize
          @accepted_charsets = []
        end

        def accept_charset! charset
          unless Encoding.find charset
            raise ArgumentError, "unknown charset #{charset.upcase.inspect}"
          end
          accepted_charsets << charset
        end
      end

      class Action
        ACTIONS = %w(OPTIONS GET HEAD POST PUT DELETE TRACE CONNECT PATCH)

        attr_reader :action

        def action= action
          unless ACTIONS.include? action
            raise ArgumentError, "Invalid action #{action.inspect}; valid actions are #{ACTIONS.map(&:inspect) * ", "}"
          end
          @action = action
        end
      end

      class Connection
        CONNECTIONS = %w(close keep-alive)

        attr_reader :connection

        def connection= value
          unless CONNECTIONS.include? value
            raise ArgumentError, "bad Connection value #{value.inspect}; valid values are #{CONNECTIONS.map(&:inspect) * ", "}"
          end
          @connection = value
        end
      end

      class ContentLength
        attr_reader :content_length

        def content_length= value
          num = Integer(value)
          if num < 0
            raise ArgumentError, "content length must not be negative"
          end
          @content_length = num
        end
      end

      class CustomHeaders
        attr_reader :custom_headers

        def initialize
          @custom_headers = {}
        end

        def add_custom_header name, value
          unless name.start_with? "X-"
            raise ArgumentError, "Custom header #{name.inspect} invalid; must start with X-"
          end
          custom_headers[name] = value
        end

        def remove_custom_header name
          custom_headers.delete name
        end
      end

      class Date
        attr_reader :date

        def date= date
          @date = date.httpdate
        end
      end

      class Host
        attr_accessor :host
      end

      class Path
        attr_writer :path

        def path
          @path or "/"
        end
      end
    end
  end
end

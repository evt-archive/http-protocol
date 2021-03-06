module HTTP
  module Protocol
    class Request
      class Headers < Headers
        define_header "Accept" do
          def initialize
            @value = []
          end

          def coerce(str)
            str.split %r{; ?}
          end

          def <<(content_type)
            validate content_type
            value << content_type
          end

          def validate(content_type)
            unless content_type.match %r{\A.+/.+\Z}
              raise Error.new "invalid content type #{content_type.inspect}"
            end
          end

          def serialized_value
            value * "; "
          end
        end

        def accept(content_type)
          handlers["Accept"] << content_type
        end

        define_header "Accept-Charset" do
          def initialize
            @value = []
          end

          def coerce(str)
            str.split %r{; ?}
          end

          def <<(charset)
            validate charset
            value << charset
          end

          def validate(charset)
            Encoding.find charset
          rescue ArgumentError => error
            raise Error.new error.message
          end

          def serialized_value
            value * "; "
          end
        end

        def accept_charset(charset)
          handlers["Accept-Charset"] << charset
        end
      end
    end
  end
end

module HTTPKit
  class Request
    class Headers < Headers::Common
      define_header "Accept" do
        def accept! content_type
          unless content_type.match %r{\A.+/.+\Z}
            raise ArgumentError, "invalid content type #{content_type.inspect}"
          end
          content_types << content_type.to_s
        end

        def value
          content_types * "; "
        end

        private

        def content_types
          @content_types ||= []
        end
      end

      define_header "Accept-Charset" do
        def accept_charset! charset
          unless Encoding.find charset
            raise ArgumentError, "unknown charset #{charset.upcase.inspect}"
          end
          accepted_charsets << charset
        end

        def value
          accepted_charsets * "; "
        end

        private

        def accepted_charsets
          @accepted_charsets ||= []
        end
      end

      define_header "Host" do
        attr_writer :host

        def value
          @host
        end
      end
    end
  end
end

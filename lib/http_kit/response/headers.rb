module HTTPKit
  class Response
    class Headers < Headers::Common
      define_header "Etag" do
        def validate etag
          unless etag.match %r{^(?:\W)?[-0-9a-f]{4,}$}
            raise ArgumentError, "invalid etag #{etag.inspect}"
          end
        end
      end

      define_header "Last-Modified" do
        def coerce str
          Time.httpdate str
        end
      end

      define_header "Server"
    end
  end
end

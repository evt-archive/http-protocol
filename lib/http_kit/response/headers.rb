module HTTPKit
  class Response
    class Headers < Headers::Common
      define_header "Access-Control-Allow-Methods"
      define_header "Access-Control-Allow-Headers"
      define_header "Access-Control-Allow-Origin"
      define_header "Access-Control-Expose-Headers"
      define_header "Location"

      define_header "Etag" do
        def validate etag
          unless etag.match %r{^(?:\W)?[-0-9a-f]{4,}$}
            raise ArgumentError, "invalid etag #{etag.inspect}"
          end
        end
      end

      define_header "Keep-Alive" do
        def initialize
          @value = {}
        end

        def coerce str
          vals = str.split ","
          vals.each_with_object Hash.new do |val, hsh|
            unless %r{^(?<property>timeout|max)=(?<number>\d+)$} =~ val
              raise ArgumentError, "invalid Keep-Alive #{str.inspect}"
            end
            hsh[property.to_sym] = number.to_i
          end
        end

        def timeout= val
          @value[:timeout] = val.to_i
        end

        def max= val
          @value[:max] = val.to_i
        end

        def serialized_value
          @value.map do |name, val| "#{name}=#{val}" end * ","
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

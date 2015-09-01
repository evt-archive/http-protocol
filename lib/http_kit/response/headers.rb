module HTTPKit
  class Response
    class Headers < Headers::Common
      define_header "Etag" do
        def assign value
          @etag = value
        end
      end

      define_header "Last-Modified" do
        def assign value
          @last_modified = value
        end
      end

      define_header "Server" do
        def assign value
          @server = value
        end
      end
    end
  end
end

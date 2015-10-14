require "webrick"
require "webrick/https"

module HTTP
  module Protocol
    module Controls
      module HTTPServer
        extend self

        attr_reader :server

        def start(ssl=nil)
          ssl ||= ENV["TEST_SERVER_HTTPS"] == "on"

          params = {
            :Port => port.to_i,
            :DocumentRoot => root,
          }

          if ssl
            cert_name = %w[CN localhost]
            params.update(
              :SSLEnable => true,
              :SSLCertName => [%W[CN localhost]]
            )
          end

          @server = WEBrick::HTTPServer.new params

          server.start
        end

        def stop
          server.shutdown
        end

        def root
          File.expand_path "../http_server_root", __FILE__
        end

        def port
          ENV.fetch "TEST_SERVER_PORT", 8888
        end
      end
    end
  end
end

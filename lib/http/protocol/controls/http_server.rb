require "webrick"

module HTTP::Protocol
  module Controls
    module HTTPServer
      extend self

      def start
        @server = WEBrick::HTTPServer.new(
          :Port => port.to_i,
          :DocumentRoot => root,
        )
        @server.start
      end

      def stop
        @server.shutdown
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

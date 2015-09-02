module HTTP::Protocol
  class Request
    class Factory
      def self.call *args
        instance = new *args
        instance.call
      end

      ACTIONS = %w(OPTIONS GET HEAD POST PUT DELETE TRACE CONNECT PATCH)
      REQUEST_LINE_REGEX = %r{^(?<action>#{ACTIONS * "|"}) (?<path>.*) HTTP/1\.1\r}

      attr_reader :request_line

      def initialize request_line
        @request_line = request_line
      end

      def call
        action, path = match_line
        Request.new action, path
      end

      def match_line
        match = REQUEST_LINE_REGEX.match request_line
        unless match
          raise Error.new "Invalid request line #{request_line.inspect}"
        end
        match.to_a.tap &:shift
      end
    end
  end
end

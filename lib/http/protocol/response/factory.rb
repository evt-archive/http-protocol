module HTTP::Protocol
  class Response
    class Factory
      def self.call *args
        instance = new *args
        instance.call
      end

      STATUS_LINE_REGEX = %r{^HTTP\/1\.1 (?<status_code>\d+) (?<status_message>[\w\s]+?)\s*\r$}

      attr_reader :status_line

      def initialize status_line
        @status_line = status_line
      end

      def call
        status_code, status_message = match_line
        Response.new status_code.to_i, status_message
      end

      def match_line
        match = STATUS_LINE_REGEX.match status_line
        unless match
          raise Error.new "Invalid status line #{status_line.inspect}"
        end
        match.to_a.tap &:shift
      end
    end
  end
end

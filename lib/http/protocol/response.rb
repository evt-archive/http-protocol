module HTTP
  module Protocol
    class Response
      include Message.new Factory

      attr_reader :status_code
      attr_reader :reason_phrase

      def initialize(status_code, reason_phrase)
        @status_code = status_code
        @reason_phrase = reason_phrase
      end

      def headers
        @headers ||= Headers.build
      end

      def status_line
        "HTTP/1.1 #{status_code} #{reason_phrase}"
      end
      alias_method :first_line, :status_line
    end
  end
end

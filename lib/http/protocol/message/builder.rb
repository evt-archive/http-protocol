module HTTP::Protocol
  Message.class_eval do
    class Builder
      HEADER_REGEX = %r{^(?<header>[-\w]+): (?<value>.*?)\s*\r$}

      attr_reader :factory
      attr_reader :message

      def initialize factory
        @factory = factory
        @in_body = false
      end

      def << data
        data.each_line do |line|
          public_send "handle_line_#{state}", line
        end
      end

      def finished_headers?
        @in_body
      end

      def handle_header line
        match = HEADER_REGEX.match line
        unless match
          raise Error.new "not a header #{line.inspect}"
        end
        header, value = match.to_a.tap &:shift
        message[header] = value
      end

      def handle_line_in_body line
        raise Error.new "tried to read the body"
      end

      def handle_line_initial line
        @message = factory[line]
      end

      def handle_line_headers line
        if line == message.newline
          @in_body = true
          return
        end
        handle_header line
      end

      def state
        if message.nil?
          :initial
        elsif finished_headers?
          :in_body
        else
          :headers
        end
      end
    end
  end
end

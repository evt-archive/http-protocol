module HTTP
  module Protocol
    module Message
      attr_writer :headers

      def [](name)
        headers[name]
      end

      def []=(name, value)
        headers[name] = value
      end

      def first_line
        fail "must be implemented"
      end

      def headers
        fail "must be implemented"
      end

      def merge_headers(new_headers)
        headers.merge! new_headers
      end

      def newline
        "\r\n"
      end

      def to_s
        [first_line, newline, headers, newline].join
      end
    end
  end
end

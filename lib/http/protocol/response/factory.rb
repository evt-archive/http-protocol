module HTTP
  module Protocol
    class Response
      class Factory
        def self.call(*args)
          instance = new *args
          instance.call
        end

        STATUS_LINE_REGEX = %r{^HTTP\/1\.1 (?<status_code>\d+) (?<reason_phrase>.+?)\s*\r$}

        attr_reader :status_line

        def initialize(status_line)
          @status_line = status_line
        end

        def call
          status_code, reason_phrase = match_line
          Response.new status_code.to_i, reason_phrase
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
end

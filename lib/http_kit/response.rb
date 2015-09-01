module HTTPKit
  class Response < Message
    require_relative "response/headers"

    STATUS_LINE_REGEX = %r{^HTTP\/1\.1 (?<status>\d+ [\w\s]+?)\s*\r$}

    def self.build
      headers = Headers.new
      new headers
    end

    attr_reader :headers
    attr_reader :state
    attr_reader :status_message

    def initialize headers
      @headers = headers
      @state = :initial
    end

    def status= str
      @status_code, @status_message = str.split " ", 2
    end

    def status
      "#{status_code} #{status_message}"
    end

    def status_code
      @status_code.to_i
    end

    def status_line= line
      _, status = STATUS_LINE_REGEX.match(line).to_a
      raise ProtocolError.new "expected status line, not #{line.inspect}" unless status
      self.status = status
    end

    def status_line
      "HTTP/1.1 #{status}"
    end

    alias_method :first_line=, :status_line=
    alias_method :first_line, :status_line
  end
end

require_relative "response/headers"

module HTTPKit
  class Response
    def self.build
      headers = Headers.new
      new headers
    end

    STATUS_LINE_REGEX = %r{^HTTP\/1\.1 (?<status>\d+ [\w\s]+?)\s*\r$}
    HEADER_REGEX = %r{^(?<header>[-\w]+): (?<value>.*?)\s*\r$}

    attr_reader :headers
    attr_reader :state
    attr_reader :status_message

    def initialize headers
      @headers = headers
      @state = :initial
    end

    def [] name
      headers[name]
    end

    def []= name, value
      headers[name] = value
    end

    def << data
      data.each_line &method(:handle_line)
    end

    def in_body?
      state == :in_body
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
      @state = :headers
    end

    def status_line
      "HTTP/1.1 #{status}"
    end

    def handle_header line
      if line == HTTPKit.newline
        headers.freeze
        @state = :in_body
      else
        _, header, value = HEADER_REGEX.match(line).to_a
        headers[header].assign value
      end
    end

    def handle_line line
      case state
      when :initial then self.status_line = line
      when :headers then handle_header line
      when :in_body then fail "tried to read body"
      end
    end

    def to_s
      [status_line, headers].join
    end
  end
end

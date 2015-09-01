require_relative "response/headers"

module HTTPKit
  class Response
    def self.build
      headers = Headers.new
      new headers
    end

    attr_reader :headers
    attr_reader :status_message

    def initialize headers
      @headers = headers
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

    def state
      if status.to_i.zero?
        :initial
      elsif in_body?
        :body
      else
        :headers
      end
    end

    def in_body?
      headers.frozen?
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
      /^HTTP\/1\.1 (?<status>\d+ [\w\s]+?)\s*\r$/ =~ line
      raise ProtocolError.new "expected status line" unless status
      self.status = status
    end

    def handle_header line
      if line == HTTPKit.newline
        headers.freeze
      else
        /^(?<header>[-\w]+): (?<value>.*?)\s*\r$/ =~ line
        headers[header].assign value
      end
    end

    def handle_line line
      case state
      when :initial then self.status_line = line
      when :headers then handle_header line
      else
      end
    end
  end
end

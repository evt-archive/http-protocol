module HTTPKit
  class Request < Message
    require_relative "request/headers"

    ACTIONS = %w(OPTIONS GET HEAD POST PUT DELETE TRACE CONNECT PATCH)
    REQUEST_LINE_REGEX = %r{^(?<action>[A-Z]+) (?<path>.*) HTTP/1\.1\r}

    def self.build action = nil, path = nil
      headers = Headers.new
      instance = new headers
      instance.action = action if action
      instance.path = path if path
      instance
    end

    attr_reader :action
    attr_writer :path
    attr_reader :state

    def initialize headers
      @headers = headers
      @state = :initial
    end

    def action= action
      unless ACTIONS.include? action
        raise ProtocolError.new "Invalid action #{action.inspect}; valid actions are #{ACTIONS.map(&:inspect) * ", "}"
      end
      @action = action
    end

    def request_line
      %{#{action} #{path} HTTP/1.1\r\n}
    end

    def request_line= str
      _, action, path = REQUEST_LINE_REGEX.match(str).to_a
      raise ProtocolError.new "expected request line, not #{str}" unless action
      self.action = action
      self.path = path
    end

    alias_method :first_line=, :request_line=
    alias_method :first_line, :request_line

    def path
      @path or "/"
    end
  end
end

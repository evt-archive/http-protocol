require_relative "request/headers"

module HTTPKit
  class Request
    ACTIONS = %w(OPTIONS GET HEAD POST PUT DELETE TRACE CONNECT PATCH)

    def self.build action, path = "/"
      instance = new action, path
      instance.headers = Headers.new
      instance
    end

    attr_reader :action
    attr_accessor :headers
    attr_accessor :path

    def initialize action = nil, path = nil
      self.action = action if action
      self.path = path if path
    end

    def [] name
      headers[name]
    end

    def []= name, value
      headers[name] = value.to_s
    end

    def action= action
      unless ACTIONS.include? action
        raise ArgumentError, "Invalid action #{action.inspect}; valid actions are #{ACTIONS.map(&:inspect) * ", "}"
      end
      @action = action
    end

    def copy
      instance = dup
      instance.headers = headers.copy
      instance
    end

    def request_line
      %{#{action} #{path} HTTP/1.1\r\n}
    end

    def request_line= str
      %r{^(?<action>[A-Z]+) (?<path>.*) HTTP/1\.1\r$} =~ str
      raise ProtocolError.new "expected request line" unless action
      self.action = action
      self.path = path
    end

    def to_s
      [request_line, headers].join
    end
  end
end

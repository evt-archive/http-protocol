module HTTPKit
  class Request < Message
    require_relative "request/headers"

    ACTIONS = %w(OPTIONS GET HEAD POST PUT DELETE TRACE CONNECT PATCH)
    REQUEST_LINE_REGEX = %r{^(?<action>[A-Z]+) (?<path>.*) HTTP/1\.1\r}

    def self.build action = nil, path = "/"
      instance = new action, path
      instance.headers = Headers.new
      instance
    end

    attr_reader :action
    attr_accessor :headers
    attr_accessor :path
    attr_reader :state

    def initialize action = nil, path = nil
      self.action = action if action
      self.path = path if path
      @state = :initial
    end

    def [] name
      headers[name]
    end

    def []= name, value
      headers[name] = value
    end

    def << data
      data.each_line do |line|
        case state
        when :initial then
          self.request_line = line
          @state = :headers
        when :headers then
          if line == HTTPKit.newline
            headers.freeze
            @state = :in_body
          else
            _, header, value = HEADER_REGEX.match(line).to_a
            headers[header].assign value
          end
        when :in_body then fail "tried to read body"
        end
      end
    end

    def in_body?
      state == :in_body
    end

    def action= action
      unless ACTIONS.include? action
        raise ProtocolError.new "Invalid action #{action.inspect}; valid actions are #{ACTIONS.map(&:inspect) * ", "}"
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
      _, action, path = REQUEST_LINE_REGEX.match(str).to_a
      raise ProtocolError.new "expected request line, not #{str}" unless action
      self.action = action
      self.path = path
    end

    def to_s
      [request_line, headers].join
    end
  end
end

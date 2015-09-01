require_relative "request/headers"

module HTTPKit
  class Request
    ACTIONS = %w(OPTIONS GET HEAD POST PUT DELETE TRACE CONNECT PATCH)

    def self.build
      headers = Headers.new
      new headers
    end

    extend Forwardable
    def_delegators :headers, :add_custom_header, :accept!, :accept_charset!,
      :connection=, :content_length=, :date=, :host=, :remove_custom_header

    attr_reader :action
    attr_accessor :headers
    attr_writer :path

    def initialize headers
      @headers = headers
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

    def path
      @path or "/"
    end

    def request_line
      %{#{action} #{path} HTTP/1.1\r\n}
    end

    def to_s
      [request_line, headers].join
    end
  end
end

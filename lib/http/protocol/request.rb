require_relative "request/factory"
require_relative "request/headers"

module HTTP::Protocol
  class Request
    include Message.new Factory

    def self.build request_line
      Builder.(request_line)
    end

    attr_reader :action
    attr_reader :path

    def initialize action, path
      @action = action
      @path = path
    end

    def headers
      @headers ||= Headers.new
    end

    def request_line
      "#{action} #{path} HTTP/1.1"
    end
    alias_method :first_line, :request_line
  end
end

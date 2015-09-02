require_relative "response/factory"
require_relative "response/headers"

module HTTPKit
  class Response
    include Message.new Factory

    attr_reader :status_code
    attr_reader :status_message

    def initialize status_code, status_message
      @status_code = status_code
      @status_message = status_message
    end

    def headers
      @headers ||= Headers.new
    end

    def status_line
      "HTTP/1.1 #{status_code} #{status_message}"
    end
    alias_method :first_line, :status_line
  end
end

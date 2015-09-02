require_relative "headers/common"
require_relative "headers/define_header"
require_relative "headers/handler"
require_relative "headers/resolve"

module HTTP::Protocol
  class Headers
    extend DefineHeader
    extend Resolve
    include Common

    attr_accessor :custom_headers

    def initialize
      @custom_headers = {}
    end

    def accept! content_type
      handlers["Accept"].add_content_type content_type
    end

    def accept_charset! charset
      handlers["Accept-Charset"].add_charset charset
    end

    def [] name
      handlers[name]
    end

    def []= name, str
      if str.nil?
        handlers.delete name
      else
        handlers[name].assign str
      end
    end

    def handlers
      @handlers ||= Hash.new do |hsh, header_name|
        handler = self.class.resolve header_name
        hsh[header_name] = handler
      end
    end

    def inspect
      handlers.reduce String.new do |str, (_, handler)|
        str << handler.to_s
      end
    end

    def merge other_headers
      instance = self.class.new
      instance.merge! self
      instance.merge! other_headers
      instance
    end

    def merge! other_headers
      other_headers.handlers.each do |header_name, handler|
        handlers[header_name] = handler.copy
      end
    end

    def remove_custom_header name
      custom_headers.delete name
    end

    def to_s
      str = ""
      handlers.each do |_, handler| str << handler.to_s end
      custom_headers.each do |name, value| str << "#{name}: #{value}\r\n" end
      str
    end
  end
end

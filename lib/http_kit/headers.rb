require_relative "headers/common"
require_relative "headers/resolve"

module HTTPKit
  class Headers
    extend Resolve

    attr_accessor :custom_headers

    def initialize
      @custom_headers = {}
    end

    def [] name
      handlers[name]
    end

    def []= name, handler
      handlers[name] = handler
    end

    def add_custom_header name, value
      unless name.start_with? "X-"
        raise ArgumentError, "Custom header #{name.inspect} invalid; must start with X-"
      end
      custom_headers[name] = value
    end

    def copy
      instance = self.class.new
      handlers.each do |handler_cls_name, handler|
        instance[handler_cls_name] = handler.copy
      end
      instance.custom_headers = custom_headers.dup
      instance
    end

    def handlers
      @handlers ||= Hash.new do |hsh, header_name|
        handler_cls = self.class.resolve header_name
        hsh[header_name] = handler_cls.new
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

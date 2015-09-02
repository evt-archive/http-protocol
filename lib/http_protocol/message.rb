module HTTPProtocol
  class Message < Module
    require_relative "message/builder"

    attr_reader :factory

    def initialize factory
      @factory = factory
    end

    def included cls
      cls.class_exec factory do |factory|
        include InstanceMethods

        define_singleton_method :make do |first_line|
          factory.(first_line)
        end

        define_singleton_method :builder do
          factory_method = method :make
          Builder.new factory_method
        end
      end
    end

    module InstanceMethods
      attr_writer :headers

      def [] name
        headers[name]
      end

      def []= name, value
        headers[name] = value
      end

      def first_line
        fail "must be implemented"
      end

      def headers
        fail "must be implemented"
      end

      def newline
        "\r\n"
      end

      def to_s
        [first_line, newline, headers, newline].join
      end
    end
  end
end

module HTTP::Protocol
  class Headers
    module DefineHeader
      def define_header header_name, &blk
        handler_cls_name = Util.to_camel_case header_name

        handler_cls = Class.new Handler
        handler_cls.class_exec &blk if block_given?
        const_set handler_cls_name, handler_cls

        writer = Util.to_snake_case handler_cls_name
        writer << "="
        define_method writer do |value|
          self[header_name].assign value
        end
      end
    end
  end
end

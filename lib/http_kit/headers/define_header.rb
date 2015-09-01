module HTTPKit
  class Headers
    module DefineHeader
      def define_header header_name, &blk
        handler_cls_name = header_name.delete "-"

        handler_cls = Class.new Handler
        handler_cls.class_exec &blk
        const_set handler_cls_name, handler_cls

        methods = handler_cls.public_instance_methods - Handler.instance_methods
        methods.each do |method_name|
          define_method method_name do |*args, &blk|
            self[header_name].public_send method_name, *args, &blk
          end
        end
      end
    end
  end
end

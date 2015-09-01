module HTTPKit
  class Headers
    module Resolve
      def resolve header_name
        if header_name.start_with? "X-"
          return Handler::CustomHeader.new header_name
        end

        handler_cls_name = Util.to_camel_case header_name

        cls = self
        until cls == Headers
          if const_defined? handler_cls_name
            subclass = const_get handler_cls_name
            return subclass.new
          end
          cls = cls.superclass
        end
      end
    end
  end
end

module HTTPKit
  class Headers
    module Resolve
      def resolve header_name
        handler_cls_name = Util.to_camel_case header_name

        cls = self
        until cls == Headers
          if const_defined? handler_cls_name
            return const_get handler_cls_name
          end
          cls = cls.superclass
        end

        raise NameError, "Couldn't resolve header #{header_name.inspect}"
      end
    end
  end
end
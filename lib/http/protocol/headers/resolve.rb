module HTTP
  module Protocol
    class Headers
      module Resolve
        def resolve(header_name)
          handler_cls_name = Util.to_camel_case header_name

          cls = self
          until cls == Headers.superclass
            if cls.const_defined? handler_cls_name
              subclass = cls.const_get handler_cls_name
              return subclass.new
            end
            cls = cls.superclass
          end

          Handler::CustomHeader.new header_name
        end
      end
    end
  end
end

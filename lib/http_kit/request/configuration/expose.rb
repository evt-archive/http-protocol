module HTTPKit
  class Request
    module Configuration
      def self.included cls
        cls.extend Expose
      end

      def config_values
        @config_values ||= Hash.new do |hsh, cls|
          hsh[cls] = cls.new
        end
      end

      def copy
        instance = self.class.new
        config_values.each do |cls, value|
          instance.config_values[cls] = value.dup
        end
        instance
      end

      module Expose
        def expose value_cls, methods:
          methods.each do |method_name|
            define_method method_name do |*args, &block|
              value = config_values[value_cls]
              value.public_send method_name, *args, &block
            end
          end
        end
      end
    end
  end
end

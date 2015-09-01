module HTTPKit
  class Headers
    class Handler
      def self.header_name
        @header_name ||= begin
          str = name.split("::").last
          str.gsub! %r{(?:[a-z])(?:[A-Z])} do |camelized_str|
            dasherized_str = ""
            dasherized_str << camelized_str[0]
            dasherized_str << "-"
            dasherized_str << camelized_str[1]
            dasherized_str
          end
          str
        end
      end

      def assign *;
        fail "virtual: #{self.class}"
      end

      def copy
        other_instance = dup
        instance_variables.each do |ivar|
          value = instance_variable_get ivar
          value = value.dup if value.is_a? Enumerable
          other_instance.instance_variable_set ivar, value
        end
        other_instance
      end

      def to_s
        "#{self.class.header_name}: #{value}\r\n"
      end

      def value
        fail "virtual: #{self.class}"
      end
    end
  end
end

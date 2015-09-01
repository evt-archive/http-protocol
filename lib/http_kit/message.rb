module HTTPKit
  class Message
    HEADER_REGEX = %r{^(?<header>[-\w]+): (?<value>.*?)\s*\r$}

    attr_accessor :headers

    def [] name
      headers[name]
    end

    def []= name, value
      headers[name] = value
    end

    def copy
      instance = dup
      instance.headers = headers.copy
      instance
    end

    def to_s
      [first_line, headers, HTTPKit.newline].join
    end

    def << data
      data.each_line do |line|
        case state
        when :initial then
          self.first_line = line
          @state = :headers
        when :headers then
          if line == HTTPKit.newline
            headers.freeze
            @state = :in_body
          else
            _, header, value = HEADER_REGEX.match(line).to_a
            headers[header].assign value
          end
        when :in_body then fail "tried to read body"
        end
      end
    end

    def in_body?
      state == :in_body
    end
  end
end

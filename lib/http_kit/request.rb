module HTTPKit
  class Request
    ACTIONS = %w(OPTIONS GET HEAD POST PUT DELETE TRACE CONNECT PATCH)
    CONNECTIONS = %w(close keep-alive)

    attr_reader :accept
    attr_reader :accept_charset
    attr_reader :action
    attr_accessor :content_length
    attr_accessor :content_type
    attr_reader :connection
    attr_reader :custom_headers
    attr_reader :date
    attr_accessor :host
    attr_writer :path

    def initialize
      @custom_headers = {}
      @accept = []
      @accept_charsets = []
    end

    def accept! content_type
      if content_type.match %r{\A.+/.+\Z}
        accept << content_type.to_s
      else
        raise ArgumentError, "invalid content type #{content_type.inspect}"
      end
    end

    def accept_charset
      @accept_charsets
    end

    def accept_charset! charset
      unless Encoding.find charset
        raise ArgumentError, "unknown charset #{charset.upcase.inspect}"
      end
      @accept_charsets << charset
    end

    def action= action
      raise ArgumentError, <<-MESSAGE.chomp unless ACTIONS.include? action
Invalid action #{action.inspect}; valid actions are #{ACTIONS.map(&:inspect) * ", "}"
      MESSAGE

      @action = action
    end

    def add_custom_header name, value
      unless name.start_with? "X-"
        raise ArgumentError, "Custom header #{name.inspect} is invalid; must start with \"X-\""
      end
      @custom_headers[name] = value
    end

    def cache_control
      @cache_control or "no-cache"
    end

    def connection= value
      unless CONNECTIONS.include? value
        raise ArgumentError, "bad Connection value #{value.inspect}; valid values are #{CONNECTIONS.map(&:inspect) * ", "}"
      end
      @connection = value
    end

    def content_length= number
      num = Integer(number)
      if num < 0
        raise ArgumentError, "content length must not be negative"
      end
      @content_length = num
    end

    def copy
      new_instance = dup
      new_instance.instance_variable_set :@custom_headers, @custom_headers.dup
      new_instance.instance_variable_set :@accept, @accept.dup
      new_instance.instance_variable_set :@accept_charsets, @accept_charsets.dup
      new_instance
    end

    def date= value
      @date = value
    end

    def path
      @path or "/".freeze
    end

    def remove_custom_header name
      @custom_headers.delete name
    end

    def to_s
      lines = []
      lines << %{#{action} #{path} HTTP/1.1}
      lines << "Host: #{host}"
      lines << %{Accept: #{accept * "; "}} if accept.any?
      lines << %{Accept-Charset: #{accept_charset * "; "}} if accept_charset.any?
      lines << %{Content-Length: #{content_length}} if content_length
      lines << %{Connection: #{connection}} if connection
      lines << %{Date: #{date.httpdate}} if date

      lines.reduce "" do |str, line|
        str << line
        str << "\r\n"
        str
      end
    end
  end
end

require_relative "request/configuration"

module HTTPKit
  class Request
    include Configuration

    expose Accept, methods: %i(accept! accepted_content_types)
    expose AcceptCharset, methods: %i(accept_charset! accepted_charsets)
    expose Connection, methods: %i(connection connection=)
    expose ContentLength, methods: %i(content_length content_length=)
    expose CustomHeaders, methods: %i(add_custom_header remove_custom_header custom_headers)
    expose Date, methods: %i(date date=)
    expose Action, methods: %i(action action=)
    expose Host, methods: %i(host host=)
    expose Path, methods: %i(path path=)

    def to_s
      lines = []
      lines << %{#{action} #{path} HTTP/1.1}
      lines << %{Host: #{host}}
      if accepted_content_types.any?
        lines << %{Accept: #{accepted_content_types * "; "}}
      end
      if accepted_charsets.any?
        lines << %{Accept-Charset: #{accepted_charsets * "; "}}
      end
      lines << %{Connection: #{connection}} if connection
      lines << %{Content-Length: #{content_length}} if content_length
      lines << %{Date: #{date}} if date

      custom_headers

      lines.reduce "" do |str, line|
        str << line
        str << "\r\n"
        str
      end
    end
  end
end

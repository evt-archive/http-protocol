require "ftest/script"
require "http_kit"

request = HTTPKit::Request.new

assert :raises => ArgumentError do request.action = "get" end
assert :raises => ArgumentError do request.action = "NOTACTION" end
request.action = "GET"

assert request.action, :equals => "GET"
request.host = "example.com"

assert request.to_s, :equals => <<-HTTP
GET / HTTP/1.1\r
Host: example.com\r
HTTP

assert :raises => ArgumentError do
  request.accept! "not_a_mime_type"
end
request.accept! "text/plain"
request.accept! "application/json"
request.accept! "application/vnd+acme.v1+json"
assert request.to_s, :matches => %r{^Accept: text/plain; application/json; application/vnd\+acme\.v1\+json\r$}

assert :raises => ArgumentError do
  request.accept_charset! "not-a-charset"
end
request.accept_charset! "utf-8"
request.accept_charset! "ascii"
assert request.to_s, :matches => %r{Accept-Charset: utf-8; ascii\r$}

assert :raises => ArgumentError do
  request.connection = "not-valid"
end
request.connection = "close"
assert request.to_s, :matches => %r{^Connection: close\r$}

assert :raises => ArgumentError do
  request.content_length = -1
end
request.content_length = "55"
assert request.to_s, :matches => %r{^Content-Length: 55\r$}

request.path = "/some_resource.json"
assert request.to_s, :matches => %r{^GET /some_resource\.json HTTP/1\.1\r$}

fixed_date = Time.new 2000, 1, 1, 0, 0, 0, 0
request.date = fixed_date
assert request.to_s, :matches => %r{^Date: Sat, 01 Jan 2000 00:00:00 GMT\r$}

request.add_custom_header "X-SOME-HEADER", "foo"
assert request.custom_headers, :equals => { "X-SOME-HEADER" => "foo" }
assert :raises => ArgumentError do
  request.add_custom_header "DOES-NOT-START-WITH-X", "hi"
end

copied_request = request.copy
copied_request.remove_custom_header "X-SOME-HEADER"
assert copied_request.custom_headers, :empty => true
assert request.custom_headers, :equals => { "X-SOME-HEADER" => "foo" }

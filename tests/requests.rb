require "ftest/script"
require "http_kit"

def build_request
  request = HTTPKit::Request.build
  request.action = "GET"
  request
end

describe "setting the action" do
  request = build_request
  request.action = "POST"
  assert :raises => ArgumentError do request.action = "get" end
  assert :raises => ArgumentError do request.action = "NOTACTION" end

  assert request.action, :equals => "POST"
end

describe "setting the host" do
  request = build_request
  request.host = "example.com"
  assert request.to_s, :equals => <<-HTTP
GET / HTTP/1.1\r
Host: example.com\r
  HTTP
end

describe "setting the request line" do
  request = build_request
  request.request_line = "POST /foo.xml HTTP/1.1\r"

  assert request.path, :equals => "/foo.xml"
  assert request.action, :equals => "POST"
end

describe "accepting content types" do
  request = build_request
  request.accept! "text/plain"
  assert :raises => ArgumentError do
    request.accept! "not_a_mime_type"
  end
  request.accept! "application/json"
  request.accept! "application/vnd+acme.v1+json"

  request.copy.accept! "application/xml"

  assert request.to_s, :matches => %r{^Accept: text/plain; application/json; application/vnd\+acme\.v1\+json\r$}
end

describe "accepting character sets" do
  request = build_request
  assert :raises => ArgumentError do
    request.accept_charset! "not-a-charset"
  end
  request.accept_charset! "utf-8"
  request.accept_charset! "ascii"

  request.copy.accept_charset! "cp1252"

  assert request.to_s, :matches => %r{^Accept-Charset: utf-8; ascii}
end

describe "setting the connection header" do
  request = build_request

  assert :raises => ArgumentError do
    request.connection = "not-valid"
  end
  request.connection = "close"
  assert request.to_s, :matches => %r{^Connection: close\r$}
end

describe "setting content length" do
  request = build_request

  assert :raises => ArgumentError do
    request.content_length = -1
  end
  request.content_length = "55"
  assert request.to_s, :matches => %r{^Content-Length: 55\r$}
end

describe "setting the path" do
  request = build_request
  request.path = "/some_resource.json"
  assert request.to_s, :matches => %r{^GET /some_resource\.json HTTP/1\.1\r$}
end

describe "setting the date" do
  request = build_request
  fixed_date = Time.new 2000, 1, 1, 0, 0, 0, 0
  request.date = fixed_date
  assert request.to_s, :matches => %r{^Date: Sat, 01 Jan 2000 00:00:00 GMT\r$}
end

describe "custom headers" do
  request = build_request
  request.add_custom_header "X-SOME-HEADER", "foo"
  assert :raises => ArgumentError do
    request.add_custom_header "DOES-NOT-START-WITH-X", "hi"
  end

  copied_request = request.copy
  copied_request.remove_custom_header "X-SOME-HEADER"

  assert request.to_s, :matches => %r{^X-SOME-HEADER: foo\r$}
  refute copied_request.to_s, :matches => %r{X-SOME-HEADER: foo}
end

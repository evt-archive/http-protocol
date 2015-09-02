require "ftest/script"
require "http_kit"

def build_request action = "GET", path = "/"
  HTTPKit::Request.new action, path
end

describe "Parsing the request line" do
  request = HTTPKit::Request.make "GET /foo HTTP/1.1\r"
  assert request.action, :equals => "GET"
  assert request.path, :equals => "/foo"

  assert :raises => HTTPKit::ProtocolError do
    HTTPKit::Request.make "get /foo HTTP/1.1\r"
  end
  assert :raises => HTTPKit::ProtocolError do
    HTTPKit::Request.make "NOTACTION /foo HTTP/1.1\r"
  end
end

describe "setting the host" do
  request = build_request
  request["Host"] = "example.com"
  assert request.to_s, :equals => <<-HTTP
GET / HTTP/1.1\r
Host: example.com\r
\r
  HTTP
end

describe "accepting content types" do
  request = build_request
  request["Accept"] << "text/plain"
  assert :raises => HTTPKit::ProtocolError do
    request["Accept"] << "not_a_mime_type"
  end
  request["Accept"] << "application/json"
  request["Accept"] << "application/vnd+acme.v1+json"

  request.headers.copy["Accept"] << "application/xml"

  assert request.to_s, :matches => %r{^Accept: text/plain; application/json; application/vnd\+acme\.v1\+json\r$}
end

describe "accepting character sets" do
  request = build_request
  assert :raises => HTTPKit::ProtocolError do
    request["Accept-Charset"] << "not-a-charset"
  end
  request["Accept-Charset"] << "utf-8"
  request["Accept-Charset"] << "ascii"

  request.headers.copy["Accept-Charset"] << "cp1252"

  assert request.to_s, :matches => %r{^Accept-Charset: utf-8; ascii}
end

describe "setting the connection header" do
  request = build_request

  assert :raises => HTTPKit::ProtocolError do
    request["Connection"] = "not-valid"
  end
  request["Connection"] = "close"
  assert request.to_s, :matches => %r{^Connection: close\r$}
end

describe "setting content length" do
  request = build_request

  assert :raises => HTTPKit::ProtocolError do
    request["Content-Length"] = -1
  end
  request["Content-Length"] = "55"
  assert request.to_s, :matches => %r{^Content-Length: 55\r$}
end

describe "setting the date" do
  request = build_request
  fixed_date = Time.new 2000, 1, 1, 0, 0, 0, 0
  request["Date"] = fixed_date
  assert request.to_s, :matches => %r{^Date: Sat, 01 Jan 2000 00:00:00 GMT\r$}

  request["Date"] = nil
  refute request.to_s, :matches => %r{Date}
end

describe "custom headers" do
  request = build_request
  request["MY-CUSTOM-HEADER"] = "foo"

  copied_request_headers = request.headers.copy
  copied_request_headers["MY-CUSTOM-HEADER"] = nil

  assert request.to_s, :matches => %r{^MY-CUSTOM-HEADER: foo\r$}
  refute copied_request_headers.to_s, :matches => %r{MY-CUSTOM-HEADER}
end

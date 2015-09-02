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

describe "Setting headers" do
  request = build_request
  request["Content-Length"] = "55"
  assert request.to_s, :matches => %r{^Content-Length: 55\r$}
end

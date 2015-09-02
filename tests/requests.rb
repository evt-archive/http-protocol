require "ftest/script"
require "http_protocol"

def build_request action = "GET", path = "/"
  HTTPProtocol::Request.new action, path
end

describe "Parsing the request line" do
  request = HTTPProtocol::Request.make "GET /foo HTTP/1.1\r"
  assert request.action, :equals => "GET"
  assert request.path, :equals => "/foo"

  assert :raises => HTTPProtocol::Error do
    HTTPProtocol::Request.make "get /foo HTTP/1.1\r"
  end
  assert :raises => HTTPProtocol::Error do
    HTTPProtocol::Request.make "NOTACTION /foo HTTP/1.1\r"
  end
end

describe "Setting headers" do
  request = build_request
  request["Content-Length"] = "55"
  assert request.to_s, :matches => %r{^Content-Length: 55\r$}
end

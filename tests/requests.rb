require "ftest/script"
require "http/protocol"

def build_request action = "GET", path = "/"
  HTTP::Protocol::Request.new action, path
end

describe "Parsing the request line" do
  request = HTTP::Protocol::Request.make "GET /foo HTTP/1.1\r"
  assert request.action, :equals => "GET"
  assert request.path, :equals => "/foo"

  assert :raises => HTTP::Protocol::Error do
    HTTP::Protocol::Request.make "get /foo HTTP/1.1\r"
  end
  assert :raises => HTTP::Protocol::Error do
    HTTP::Protocol::Request.make "NOTACTION /foo HTTP/1.1\r"
  end
end

describe "Setting headers" do
  request = build_request
  request["Content-Length"] = "55"
  assert request.to_s, :matches => %r{^Content-Length: 55\r$}
end

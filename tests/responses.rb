require "ftest/script"
require "http_protocol"

def build_response
  HTTPProtocol::Response.new 200, "OK"
end

describe "Parsing the status line" do
  response = HTTPProtocol::Response.make "HTTP/1.1 200 OK\r\n"
  assert response.status_code, :equals => 200
  assert response.status_message, :equals => "OK"

  assert :raises => HTTPProtocol::Error do
    HTTPProtocol::Response.make "200 OK\r"
  end
end

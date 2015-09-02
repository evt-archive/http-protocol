require "ftest/script"
require "http_kit"

def build_response
  HTTPKit::Response.new 200, "OK"
end

describe "Parsing the status line" do
  response = HTTPKit::Response.make "HTTP/1.1 200 OK\r\n"
  assert response.status_code, :equals => 200
  assert response.status_message, :equals => "OK"

  assert :raises => HTTPKit::ProtocolError do
    HTTPKit::Response.make "200 OK\r"
  end
end

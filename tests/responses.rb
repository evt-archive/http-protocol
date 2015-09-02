require "ftest/script"
require "http/protocol"

def build_response
  HTTP::Protocol::Response.new 200, "OK"
end

describe "Parsing the status line" do
  response = HTTP::Protocol::Response.make "HTTP/1.1 200 OK\r\n"
  assert response.status_code, :equals => 200
  assert response.status_message, :equals => "OK"

  assert :raises => HTTP::Protocol::Error do
    HTTP::Protocol::Response.make "200 OK\r"
  end
end

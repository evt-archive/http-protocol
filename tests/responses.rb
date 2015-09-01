require "ftest/script"
require "http_kit"

def build_response
  HTTPKit::Response.build
end

describe "status line" do
  response = build_response
  response.status_line = "HTTP/1.1 200 OK\r\n"
  assert response.status_code, :equals => 200
  assert response.status_message, :equals => "OK"
end

describe "Etag" do
  response = build_response

  assert :raises => HTTPKit::ProtocolError do
    response["Etag"] = "not_an_etag"
  end
  response["Etag"] = "deadbeef"
end

describe "Last-Modified" do
  response = build_response

  assert :raises => HTTPKit::ProtocolError do
    response["Last-Modified"] = "not_a_date"
  end
end

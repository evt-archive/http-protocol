require_relative "./spec_init"

def establish_tcp_socket(port = 8888)
  TCPSocket.new "127.0.0.1", port
end

def simple_resource_request
  request = HTTP::Protocol::Request.new "GET", "/simple_resource.json"
  request["Host"] = "localhost"
  request["Connection"] = "close"
  request
end

describe "A simple client session" do
  tcp_socket = establish_tcp_socket
  tcp_socket.write simple_resource_request

  builder = HTTP::Protocol::Response::Builder.build
  builder << tcp_socket.gets until builder.finished_headers?

  data = tcp_socket.read

  resource = JSON.parse data, :symbolize_names => true
  test "Output" do
    assert resource == { :id => 1234, :name => "A simple resource" }
  end
end

def simple_resource_post_message
  data = <<-BODY
{
  "id": 2,
  "name": "Another simple resource"
}
  BODY

  <<-MESSAGE
POST /simple_resource.json HTTP/1.1\r
Host: localhost\r
Connection: close\r
Content-Length: #{data.size + 2}\r
\r
#{data}
\r
  MESSAGE
end

describe "A simple server session" do
  data = simple_resource_post_message
  io = StringIO.new data

  builder = HTTP::Protocol::Request::Builder.build
  builder << io.gets until builder.finished_headers?

  body = io.read

  resource = JSON.parse body, :symbolize_names => true
  specify "Output" do
    assert resource == { :id => 2, :name => "Another simple resource" }
  end
end

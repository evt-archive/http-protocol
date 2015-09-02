require "ftest/script"
require "http_kit"

require "json"
require "socket"
require "stringio"

def establish_tcp_socket
  TCPSocket.new "127.0.0.1", 8888
end

def simple_resource_request
  request = HTTPKit::Request.new "GET", "/simple_resource.json"
  request["Host"] = "localhost"
  request["Connection"] = "close"
  request
end

describe "a simple client session" do
  tcp_socket = establish_tcp_socket
  tcp_socket.write simple_resource_request

  builder = HTTPKit::Response.builder
  builder << tcp_socket.gets until builder.finished_headers?

  data = tcp_socket.read

  resource = JSON.parse data, :symbolize_names => true
  assert resource, :equals => { :id => 1234, :name => "A simple resource" }
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

describe "a simple server session" do
  data = simple_resource_post_message
  io = StringIO.new data

  builder = HTTPKit::Request.builder
  builder << io.gets until builder.finished_headers?

  body = io.read

  resource = JSON.parse body, :symbolize_names => true
  assert resource, :equals => { :id => 2, :name => "Another simple resource" }
end

require "ftest/script"
require "http_kit"

require "json"
require "socket"
require "stringio"

def establish_tcp_socket
  TCPSocket.new "127.0.0.1", 8888
end

def simple_resource_request
  request = HTTPKit::Request.build "GET", "/simple_resource.json"
  request["Host"] = "localhost"
  request["Connection"] = "close"
  request
end

describe "a simple client session" do
  tcp_socket = establish_tcp_socket
  tcp_socket.write simple_resource_request
  tcp_socket.write HTTPKit.newline

  response = HTTPKit::Response.build
  response << tcp_socket.gets until response.in_body?

  data = tcp_socket.read
  data.chomp! HTTPKit.newline

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
  data = p simple_resource_post_message
  io = StringIO.new data

  request = HTTPKit::Request.build
  request << io.gets until request.in_body?

  body = io.read
  body.chomp! HTTPKit.newline

  resource = JSON.parse body, :symbolize_names => true
  assert resource, :equals => { :id => 2, :name => "Another simple resource" }
end

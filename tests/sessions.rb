require "ftest/script"
require "http_kit"

require "json"
require "socket"

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

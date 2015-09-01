require "ftest/script"
require "http_kit"

require "json"
require "socket"

def tcp_socket
  @tcp_socket ||= TCPSocket.new "127.0.0.1", 8888
end

describe "a simple session" do
  request = HTTPKit::Request.build
  request.action = "GET"
  request.path = "/simple_resource.json"
  request.host = "localhost"
  request.connection = "close"

  logger.debug "Writing request:\n\n#{request}"

  tcp_socket.write request.to_s
  tcp_socket.write HTTPKit.newline

  response = HTTPKit::Response.build
  response << tcp_socket.gets until response.in_body?

  data = tcp_socket.read
  data.chomp! HTTPKit.newline
  resource = JSON.parse data, :symbolize_names => true
  assert resource, :equals => { :id => 1234, :name => "A simple resource" }
end

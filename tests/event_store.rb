require "ftest/script"
require "http_kit"

require "json"
require "socket"
require "securerandom"

def common_headers
  @common_headers ||=
    begin
      headers = HTTPKit::Request::Headers.new
      headers["Host"] = "localhost"
      headers
    end
end

def uuid
  SecureRandom.uuid
end

def write_event_request
  request = HTTPKit::Request.new "POST", "/streams/testStream-#{uuid}"
  request.headers = common_headers.copy
  request["Content-Type"] = "application/json"
  request
end

def establish_connection
  TCPSocket.new "127.0.0.1", "2113"
end

request = write_event_request

tcp_socket = establish_connection

describe "writing events" do
  request["ES-EventType"] = "TestEvent"
  event = JSON.pretty_generate data: "a_msg"

  request["ES-EventId"] = uuid
  request["Content-Length"] = event.size + 2

  logger.debug do "Writing event:\n\n#{request}\r\n#{event}\r\n" end
  tcp_socket.write request
  tcp_socket.write HTTPKit.newline
  tcp_socket.write event
  tcp_socket.write HTTPKit.newline

  response = HTTPKit::Response.build
  response << tcp_socket.gets until response.in_body?
  logger.debug do "Received response:\n\n#{response}" end

  if response["Connection"].value == "close"
    logger.debug do "Re-establishing connection" end
    tcp_socket.close
    tcp_socket = establish_connection
  end
end

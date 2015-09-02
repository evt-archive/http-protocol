require "ftest/script"
require "http_protocol"

require "json"
require "socket"
require "securerandom"

def common_headers
  @common_headers ||=
    begin
      headers = HTTPProtocol::Request::Headers.new
      headers["Host"] = "localhost"
      headers
    end
end

def uuid
  SecureRandom.uuid
end

def write_event_request
  request = HTTPProtocol::Request.new "POST", "/streams/testStream-#{uuid}"
  request.merge_headers common_headers
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
  request["Content-Length"] = event.size

  logger.debug do "Writing event:\n\n#{request}\r\n#{event}\r\n" end
  tcp_socket.write request
  tcp_socket.write event

  builder = HTTPProtocol::Response.builder
  builder << tcp_socket.gets until builder.finished_headers?
  response = builder.message
  logger.debug do "Received response:\n\n#{response}" end

  if response["Connection"].value == "close"
    logger.debug do "Re-establishing connection" end
    tcp_socket.close
    tcp_socket = establish_connection
  end
end

require "ftest/script"
require "http/protocol"

require "json"
require "socket"
require "securerandom"

def common_headers
  @common_headers ||=
    begin
      headers = HTTP::Protocol::Request::Headers.new
      headers["Host"] = "localhost"
      headers
    end
end

def uuid
  SecureRandom.uuid
end

def write_event_request
  request = HTTP::Protocol::Request.new "POST", "/streams/testStream-#{uuid}"
  request.merge_headers common_headers
  request["Content-Type"] = "application/json"
  request["ES-EventType"] = "TestEvent"
  request["ES-EventId"] = uuid
  request
end

def read_events_request
  request = HTTP::Protocol::Request.new "GET", "/streams/$ce-testStream/0/forward/50"
  request.merge_headers common_headers
  request["Accept"] << "application/json"
  request
end

def establish_connection
  TCPSocket.new "127.0.0.1", "2113"
end

describe "Writing events" do
  tcp_socket = establish_connection
  request = write_event_request

  event = JSON.pretty_generate data: "a_msg"

  request["Content-Length"] = event.size

  logger.debug do "Writing event:\n\n#{request}\r\n#{event}\r\n" end
  tcp_socket.write request
  tcp_socket.write event

  builder = HTTP::Protocol::Response.builder
  builder << tcp_socket.gets until builder.finished_headers?
  response = builder.message
  logger.debug do "Received response:\n\n#{response}" end

  if response["Connection"].value == "close"
    logger.debug do "Re-establishing connection" end
    tcp_socket.close
    tcp_socket = establish_connection
  end
end

describe "Reading events" do
  tcp_socket = establish_connection
  request = read_events_request

  logger.debug do "Reading stream:\n\n#{request}\r\n" end
  tcp_socket.write request

  builder = HTTP::Protocol::Response.builder
  builder << tcp_socket.gets until builder.finished_headers?
  response = builder.message
  logger.debug do "Received response:\n\n#{response}" end

  length = response["Content-Length"].to_i
  data = tcp_socket.read length

  logger.debug "Stream data:\n\n#{data}"
end

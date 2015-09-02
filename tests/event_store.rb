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

def write_event_request stream_id = uuid
  request = HTTP::Protocol::Request.new "POST", "/streams/testStream-#{stream_id}"
  request.merge_headers common_headers
  request["Content-Type"] = "application/json"
  request["ES-EventType"] = "TestEvent"
  request["ES-EventId"] = uuid
  request
end

def write_some_event tcp_socket, stream_id, event
  request = write_event_request stream_id

  request["Content-Length"] = event.size

  logger.debug do "Writing event:\n\n#{request}\r\n#{event}\r\n" end

  tcp_socket.write request
  tcp_socket.write event

  builder = HTTP::Protocol::Response.builder
  builder << tcp_socket.gets until builder.finished_headers?

  response = builder.message

  logger.debug "Finished writing event:\n\n#{response}"

  if response["Connection"].value == "close"
    logger.debug do "Re-establishing connection" end
    tcp_socket.close
    tcp_socket = establish_connection
  end

  response
end

def read_events_request stream_id = uuid, start = 0
  request = HTTP::Protocol::Request.new "GET", "/streams/testStream-#{stream_id}/#{start}/forward/1?embed=body"
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
  write_some_event tcp_socket, "deadbeef", "an-event"
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

describe "Long polling" do
  stream_id = uuid
  poll_period = 3
  write_socket = establish_connection
  read_socket = establish_connection

  write_some_event write_socket, stream_id, "creates-stream"

  request = read_events_request stream_id, 1
  request["ES-LongPoll"] = poll_period

  logger.debug do "Reading stream:\n\n#{request}\r\n" end
  read_socket.write_nonblock request

  rd, _, _ = IO.select [read_socket], [], [], 0
  assert rd, :nil => true

  # Writing a new event will cause the socket to have data
  write_some_event write_socket, stream_id, "long-poll"

  logger.debug "The event should be written to event store and pushed to the read socket"
  rd, _, _ = IO.select [read_socket], [], [], poll_period
  refute rd, :nil => true

  builder = HTTP::Protocol::Response.builder
  builder << read_socket.gets until builder.finished_headers?
  response = builder.message
  logger.debug do "Received response:\n\n#{response}" end

  json = read_socket.read response["Content-Length"].to_i
  logger.debug "Stream data:\n\n#{json}"

  batch = JSON.parse json, :symbolize_names => true
  entries = batch.fetch :entries
  data = entries.map do |entry| entry.fetch :data end

  assert data, :equals => ["long-poll"]
end

# HTTP::Protocol

Library aimed at facilitating custom HTTP clients by providing tooling for assembling request and responses.

## Why?

The existing HTTP clients for ruby today either employ a synchronous I/O model or are else coupled to an async library such as Celluloid or EM. None of the clients expose the underlying TCP socket that would afford the programmer the choice of I/O and concurrency patterns.

## Building a Basic Client

There are examples in `tests/`, but for now:

##### 1. Create a request

```ruby
# Instantiate the request object
request = HTTP::Protcol::Request.new "GET", "index.html"

# Set the Host as well as indicate we don't want a persistent connection.
request["Host"] = "www.google.com"
request["Connection"] = "close"
```

##### 2. Connect to the server

```ruby
require "socket"
socket = TCPSocket.new "google.com", "80"
```

##### 3. Write the request

```ruby
socket.write request
```

Note that if you need to submit a request body, for instance if you are making a POST, that `socket.write request` will stop after writing the headers. You are free to write any request body you want, however you want. Just keep in mind that you likely need to have set either `Content-Length` or `Transfer-Encoding`.

##### 4. Reading the response

To read a response, you need to instantiate a response builder. As you read from the socket, you'll feed that data into the builder. When you are finished reading the headers, you then need to read the response body (if there is one).

```ruby
builder = HTTP::Protocol::Response.builder
builder << tcp_socket.gets until builder.finished_headers?

# Extract the content length from the response
response = builder.message
length = response["Content-Length"].to_i

# Read the amount of data indicated by the server
data = tcp_socket.read length
```

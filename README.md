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

## Advanced Techniques

##### Setting headers

`HTTP::Protocol` exposes a semantic API for setting headers. For instance, instead of setting `Accept` to `application/json; text/plain`, you can set them one at a time:

```ruby
# The handler for Accept manages a list of content types internally; you can
# shovel them in one by one.
request["Accept"] << "application/json"
```

See `tests/headers.rb` for usage examples of all of the headers that `HTTP::Protocol` knows about. The list is expected to grow over time. Any header that is not explicitly handled by `HTTP::Protocol` is treated as a custom header, which you can simply treat as a string:

```ruby
# Will write out Some-Header: foo
request["Some-Header"] = "foo"
```

##### Merging headers

Often, an HTTP client will have to use the same set of headers for every request. For example, if you are interacting with a JSON api, you will usually want to set `Accept: application/json`. To avoid needing to do this every single time, you can instantiate a set of common headers and merge them into your requests:

```ruby
common_headers = HTTP::Protocol::Request::Headers.new
common_headers["Accept"] = "application/json"

request = HTTP::Protocol::Request.new "GET", "/some_resource.json"
request.merge_headers common_headers
```

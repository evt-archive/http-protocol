require_relative "./spec_init"

describe "Parsing" do
  specify "Valid request line" do
    request = HTTP::Protocol::Request.make "GET /foo HTTP/1.1\r"
    assert request.action == "GET"
    assert request.path == "/foo"
  end

  specify "Invalid actions" do
    errors = 0

    begin
      HTTP::Protocol::Request.make "get /foo HTTP/1.1\r"
    rescue HTTP::Protocol::Error
      errors += 1
    end
    assert errors == 1

    begin
      HTTP::Protocol::Request.make "NOTACTION /foo HTTP/1.1\r"
    rescue HTTP::Protocol::Error
      errors += 1
    end
    assert errors == 2
  end
end

describe "Setting headers" do
  specify "Content-Length" do
    request = HTTP::Protocol::Request.new "GET", "/"
    request["Content-Length"] = "55"
    assert request.to_s.match(%r{^Content-Length: 55\r$})
  end
end
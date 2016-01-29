require_relative "./spec_init"

context "Parsing" do
  test "Valid request line" do
    request = HTTP::Protocol::Request::RequestLineParser.("GET /foo HTTP/1.1\r")
    assert request.action == "GET"
    assert request.path == "/foo"
  end

  test "Invalid actions" do
    errors = 0

    begin
      HTTP::Protocol::Request::RequestLineParser.("get /foo HTTP/1.1\r")
    rescue HTTP::Protocol::Error
      errors += 1
    end
    assert errors == 1

    begin
      HTTP::Protocol::Request::RequestLineParser.("NOTACTION /foo HTTP/1.1\r")
    rescue HTTP::Protocol::Error
      errors += 1
    end
    assert errors == 2
  end
end

context "Setting headers" do
  test "Content-Length" do
    request = HTTP::Protocol::Request.new "GET", "/"
    request["Content-Length"] = "55"
    assert request.to_s.match(%r{^Content-Length: 55\r$})
  end
end

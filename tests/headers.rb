require "ftest/script"
require "http_kit"

require "time"

def build_headers
  HTTPKit::Headers.new
end

def fixed_time
  Time.new 2000, 1, 1, 0, 0, 0, 0
end

describe "Common headers" do
  describe "Connection" do
    headers = build_headers

    assert :raises => HTTPKit::ProtocolError do
      headers["Connection"] = "not-valid"
    end
    headers["Connection"] = "close"

    assert headers.to_s, :matches => %r{^Connection: close\r$}
  end

  describe "custom headers" do
    headers = build_headers

    headers["MY-CUSTOM-HEADER"] = "foo"

    assert headers.to_s, :matches => %r{^MY-CUSTOM-HEADER: foo\r$}
  end

  describe "Date" do
    headers = build_headers

    headers["Date"] = fixed_time

    assert headers.to_s, :matches => /^Date: Sat, 01 Jan 2000 00:00:00 GMT\r$/
  end

  describe "Unsetting a header" do
    headers = build_headers

    headers["Date"] = fixed_time
    headers["Date"] = nil

    refute headers.to_s, :matches => /Date/
  end
end

describe "Request headers" do
  def build_request_headers
    HTTPKit::Request::Headers.new
  end

  describe "Accept" do
    headers = build_request_headers

    headers["Accept"] << "text/plain"
    assert :raises => HTTPKit::ProtocolError do
      headers["Accept"] << "not_a_mime_type"
    end
    headers["Accept"] << "application/json"
    headers["Accept"] << "application/vnd+acme.v1+json"

    assert headers.to_s, :matches => %r{^Accept: text/plain; application/json; application/vnd\+acme\.v1\+json\r$}
  end

  describe "Accept-Charset" do
    headers = build_request_headers

    assert :raises => HTTPKit::ProtocolError do
      headers["Accept-Charset"] << "not-a-charset"
    end
    headers["Accept-Charset"] << "utf-8"
    headers["Accept-Charset"] << "ascii"

    assert headers.to_s, :matches => /^Accept-Charset: utf-8; ascii\r$/
  end
end

describe "Response headers" do
  def build_response_headers
    HTTPKit::Response::Headers.new
  end

  describe "Etag" do
    headers = build_response_headers

    assert :raises => HTTPKit::ProtocolError do
      headers["Etag"] = "not_an_etag"
    end
    headers["Etag"] = "deadbeef"

    assert headers.to_s, :matches => /^Etag: deadbeef\r$/
  end

  describe "Last-Modified" do
    headers = build_response_headers

    assert :raises => HTTPKit::ProtocolError do
      headers["Last-Modified"] = "not_a_date"
    end
    headers["Last-Modified"] = fixed_time

    assert headers.to_s, :matches => /^Last-Modified: Sat, 01 Jan 2000 00:00:00 GMT\r$/
  end
end

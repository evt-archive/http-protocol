require "ftest/script"
require "http/protocol"

require "time"

def build_headers
  HTTP::Protocol::Headers.new
end

def fixed_time
  Time.new 2000, 1, 1, 0, 0, 0, 0
end

describe "Common headers" do
  describe "Connection" do
    headers = build_headers

    assert :raises => HTTP::Protocol::Error do
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

describe "Merging headers" do
  def build_source_headers
    source = build_headers
    source["Content-Length"] = 55
    source["CUSTOM-HEADER-1"] = "foo"
    source["CUSTOM-HEADER-2"] = "bar"
    source["Date"] = fixed_time
    source
  end

  def build_target_headers
    target = build_headers
    target["Content-Length"] = 88
    target["CUSTOM-HEADER-1"] = "baz"
    target
  end

  describe "Destructive" do
    source = build_source_headers
    target = build_target_headers

    source.merge! target

    assert source.to_s, :matches => /Content-Length: 88/
    assert source.to_s, :matches => /CUSTOM-HEADER-1: baz/
    assert source.to_s, :matches => /CUSTOM-HEADER-2: bar/
    assert source.to_s, :matches => /Date: Sat, 01 Jan 2000 00:00:00 GMT/
  end

  describe "Non destructive" do
    source = build_source_headers
    target = build_target_headers

    merged = source.merge target

    assert merged.to_s, :matches => /Content-Length: 88/
    assert merged.to_s, :matches => /CUSTOM-HEADER-1: baz/
    assert merged.to_s, :matches => /CUSTOM-HEADER-2: bar/
    assert merged.to_s, :matches => /Date: Sat, 01 Jan 2000 00:00:00 GMT/
    assert source.to_s, :matches => /Content-Length: 55/
    assert source.to_s, :matches => /CUSTOM-HEADER-1: foo/
  end
end

describe "Request headers" do
  def build_request_headers
    HTTP::Protocol::Request::Headers.new
  end

  describe "Accept" do
    headers = build_request_headers

    headers.accept "text/plain"
    assert :raises => HTTP::Protocol::Error do
      headers.accept "not_a_mime_type"
    end
    headers.accept "application/json"
    headers.accept "application/vnd+acme.v1+json"

    assert headers.to_s, :matches => %r{^Accept: text/plain; application/json; application/vnd\+acme\.v1\+json\r$}
  end

  describe "Accept-Charset" do
    headers = build_request_headers

    assert :raises => HTTP::Protocol::Error do
      headers.accept_charset "not-a-charset"
    end
    headers.accept_charset "utf-8"
    headers.accept_charset "ascii"

    assert headers.to_s, :matches => /^Accept-Charset: utf-8; ascii\r$/
  end
end

describe "Response headers" do
  def build_response_headers
    HTTP::Protocol::Response::Headers.new
  end

  describe "Etag" do
    headers = build_response_headers

    assert :raises => HTTP::Protocol::Error do
      headers["Etag"] = "not_an_etag"
    end
    headers["Etag"] = "deadbeef"

    assert headers.to_s, :matches => /^Etag: deadbeef\r$/
  end

  describe "Last-Modified" do
    headers = build_response_headers

    assert :raises => HTTP::Protocol::Error do
      headers["Last-Modified"] = "not_a_date"
    end
    headers["Last-Modified"] = fixed_time

    assert headers.to_s, :matches => /^Last-Modified: Sat, 01 Jan 2000 00:00:00 GMT\r$/
  end
end

require_relative "./spec_init"

def build_headers
  HTTP::Protocol::Headers.build
end

def fixed_time
  Time.new 2000, 1, 1, 0, 0, 0, 0
end

describe "Common headers" do
  describe "Connection" do
    headers = build_headers

    specify "Validation" do
      errors = 0
      begin
        headers["Connection"] = "not-valid"
      rescue HTTP::Protocol::Error
        errors += 1
      end
      assert errors == 1
      headers["Connection"] = "close"
    end

    specify "Set on output" do
      assert headers.to_s.match(%r{^Connection: close\r$})
    end
  end

  describe "custom headers" do
    headers = build_headers

    headers["MY-CUSTOM-HEADER"] = "foo"

    specify "Set on output" do
      assert headers.to_s.match(%r{^MY-CUSTOM-HEADER: foo\r$})
    end
  end

  describe "Date" do
    headers = build_headers

    headers["Date"] = fixed_time

    specify "Set on output" do
      assert headers.to_s.match(/^Date: Sat, 01 Jan 2000 00:00:00 GMT\r$/)
    end
  end

  describe "Unsetting a header" do
    headers = build_headers

    headers["Date"] = fixed_time
    headers["Date"] = nil

    specify "Set on output" do
      assert !headers.to_s.match(/Date/)
    end
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
    specify "Set on output" do
      source = build_source_headers
      target = build_target_headers

      source.merge! target

      assert source.to_s.match(/Content-Length: 88/)
      assert source.to_s.match(/CUSTOM-HEADER-1: baz/)
      assert source.to_s.match(/CUSTOM-HEADER-2: bar/)
      assert source.to_s.match(/Date: Sat, 01 Jan 2000 00:00:00 GMT/)
    end
  end

  describe "Non destructive" do
    specify "Set on output" do
      source = build_source_headers
      target = build_target_headers

      merged = source.merge target

      assert merged.to_s.match(/Content-Length: 88/)
      assert merged.to_s.match(/CUSTOM-HEADER-1: baz/)
      assert merged.to_s.match(/CUSTOM-HEADER-2: bar/)
      assert merged.to_s.match(/Date: Sat, 01 Jan 2000 00:00:00 GMT/)
      assert source.to_s.match(/Content-Length: 55/)
      assert source.to_s.match(/CUSTOM-HEADER-1: foo/)
    end
  end
end

describe "Request headers" do
  def build_request_headers
    HTTP::Protocol::Request::Headers.build
  end

  describe "Accept" do
    specify "Validation" do
      headers = build_request_headers

      errors = 0
      begin
        headers.accept "not_a_mime_type"
      rescue HTTP::Protocol::Error
        errors += 1
      end
      assert errors == 1
    end

    specify "Set on output" do
      headers = build_request_headers
      headers.accept "text/plain"
      headers.accept "application/json"
      headers.accept "application/vnd+acme.v1+json"
      assert headers.to_s.match(%r{^Accept: text/plain; application/json; application/vnd\+acme\.v1\+json\r$})
    end
  end

  describe "Accept-Charset" do
    specify "Validation" do
      headers = build_request_headers

      errors = 0
      begin
        headers.accept_charset "not-a-charset"
      rescue HTTP::Protocol::Error
        errors += 1
      end

      assert errors == 1
    end

    specify "Set on output" do
      headers = build_request_headers
      headers.accept_charset "utf-8"
      headers.accept_charset "ascii"
      assert headers.to_s.match(/^Accept-Charset: utf-8; ascii\r$/)
    end
  end
end

describe "Response headers" do
  def build_response_headers
    HTTP::Protocol::Response::Headers.build
  end

  describe "Etag" do
    specify "Validation" do
      headers = build_response_headers

      errors = 0
      begin
        headers["Etag"] = "not_an_etag"
      rescue HTTP::Protocol::Error
        errors += 1
      end

      assert errors == 1
    end

    specify "Set on output" do
      headers = build_response_headers

      headers["Etag"] = "deadbeef"

      assert headers.to_s.match(/^Etag: deadbeef\r$/)
    end
  end

  describe "Last-Modified" do
    specify "Validation" do
      headers = build_response_headers
      errors = 0
      begin
        headers["Last-Modified"] = "not_a_date"
      rescue HTTP::Protocol::Error
        errors += 1
      end
    end

    specify "Set on output" do
      headers = build_response_headers
      headers["Last-Modified"] = fixed_time
      assert headers.to_s.match(/^Last-Modified: Sat, 01 Jan 2000 00:00:00 GMT\r$/)
    end
  end
end

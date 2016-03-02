require_relative "./bench_init"

def build_headers
  HTTP::Protocol::Headers.build
end

def fixed_time
  Time.new 2000, 1, 1, 0, 0, 0, 0
end

context "Common headers" do
  context "Connection" do
    test "Validation" do
      headers = build_headers

      errors = 0
      begin
        headers["Connection"] = "not-valid"
      rescue HTTP::Protocol::Error
        errors += 1
      end
      assert errors == 1
    end

    test 'Case Insensitivity' do
      headers = build_headers

      headers['Connection'] = 'KEEP-ALIVE'

      assert headers['Connection'].to_s == 'keep-alive'
    end

    test "Set on output" do
      headers = build_headers
      headers["Connection"] = "close"
      assert headers.to_s.match(%r{^Connection: close\r$})
    end
  end

  context "custom headers" do
    headers = build_headers

    headers["MY-CUSTOM-HEADER"] = "foo"

    test "Set on output" do
      assert headers.to_s.match(%r{^MY-CUSTOM-HEADER: foo\r$})
    end
  end

  context "Date" do
    headers = build_headers

    headers["Date"] = fixed_time

    test "Set on output" do
      assert headers.to_s.match(/^Date: Sat, 01 Jan 2000 00:00:00 GMT\r$/)
    end
  end

  context "Unsetting a header" do
    headers = build_headers

    headers["Date"] = fixed_time
    headers["Date"] = nil

    test "Set on output" do
      assert !headers.to_s.match(/Date/)
    end
  end
end

context "Merging headers" do
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

  context "Destructive" do
    test "Set on output" do
      source = build_source_headers
      target = build_target_headers

      source.merge! target

      assert source.to_s.match(/Content-Length: 88/)
      assert source.to_s.match(/CUSTOM-HEADER-1: baz/)
      assert source.to_s.match(/CUSTOM-HEADER-2: bar/)
      assert source.to_s.match(/Date: Sat, 01 Jan 2000 00:00:00 GMT/)
    end
  end

  context "Non destructive" do
    test "Set on output" do
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

context "Request headers" do
  def build_request_headers
    HTTP::Protocol::Request::Headers.build
  end

  context "Accept" do
    test "Validation" do
      headers = build_request_headers

      errors = 0
      begin
        headers.accept "not_a_mime_type"
      rescue HTTP::Protocol::Error
        errors += 1
      end
      assert errors == 1
    end

    test "Set on output" do
      headers = build_request_headers
      headers.accept "text/plain"
      headers.accept "application/json"
      headers.accept "application/vnd+acme.v1+json"
      assert headers.to_s.match(%r{^Accept: text/plain; application/json; application/vnd\+acme\.v1\+json\r$})
    end
  end

  context "Accept-Charset" do
    test "Validation" do
      headers = build_request_headers

      errors = 0
      begin
        headers.accept_charset "not-a-charset"
      rescue HTTP::Protocol::Error
        errors += 1
      end

      assert errors == 1
    end

    test "Set on output" do
      headers = build_request_headers
      headers.accept_charset "utf-8"
      headers.accept_charset "ascii"
      assert headers.to_s.match(/^Accept-Charset: utf-8; ascii\r$/)
    end
  end
end

context "Response headers" do
  def build_response_headers
    HTTP::Protocol::Response::Headers.build
  end

  context "Etag" do
    context "Validation" do
      headers = build_response_headers

      test "Correct etag" do
        begin
          headers["Etag"] = %{"some-etag"}
        rescue HTTP::Protocol::Error => error
        end

        assert error.nil?
      end

      test "Weak is included" do
        begin
          headers["Etag"] = %{W/"!"}
        rescue HTTP::Protocol::Error => error
        end

        assert error.nil?
      end

      test "Quotes are not required" do
        begin
          headers["Etag"] = %{some-etag}
        rescue HTTP::Protocol::Error => error
        end

        assert error.nil?
      end

      test "Spaces aren't allowed" do
        begin
          headers["Etag"] = %{"some etag"}
        rescue HTTP::Protocol::Error => error
        end

        assert error
      end
    end

    test "Set on output" do
      headers = build_response_headers

      headers["Etag"] = %{"some-etag"}

      assert headers.to_s.match(/^Etag: "some-etag"\r$/)
    end
  end

  context "Last-Modified" do
    test "Validation" do
      headers = build_response_headers
      errors = 0
      begin
        headers["Last-Modified"] = "not_a_date"
      rescue HTTP::Protocol::Error
        errors += 1
      end
    end

    test "Set on output" do
      headers = build_response_headers
      headers["Last-Modified"] = fixed_time
      assert headers.to_s.match(/^Last-Modified: Sat, 01 Jan 2000 00:00:00 GMT\r$/)
    end
  end
end

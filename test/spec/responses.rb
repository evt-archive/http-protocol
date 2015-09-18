require_relative "./spec_init"

describe "Parsing" do
  specify "Valid status line" do
    response = HTTP::Protocol::Response::StatusLineParser.call "HTTP/1.1 200 OK\r\n"
    assert response.status_code == 200
    assert response.reason_phrase == "OK"
  end

  specify "Invalid status line" do
    errors = 0
    begin
      HTTP::Protocol::Response::StatusLineParser.call "200 OK\r"
    rescue HTTP::Protocol::Error
      errors += 1
    end
    assert errors == 1
  end
end

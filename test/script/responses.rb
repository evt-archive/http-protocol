require_relative "./test_script_init"

describe "Parsing the status line" do
  response = HTTP::Protocol::Response.make "HTTP/1.1 200 OK\r\n"
  assert response.status_code == 200
  assert response.reason_phrase == "OK"

  errors = 0
  begin
    HTTP::Protocol::Response.make "200 OK\r"
  rescue HTTP::Protocol::Error
    errors += 1
  end
  assert errors == 1
end

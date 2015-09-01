module HTTPKit
  class Response
    class Headers < Headers::Common
      define_header "Etag"
      define_header "Last-Modified"
      define_header "Server"
    end
  end
end

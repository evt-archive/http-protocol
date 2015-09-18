module HTTP
  module Protocol
    class Request
      class Builder < Message::Builder
        def self.build
          factory = -> first_line do
            RequestLineParser.(first_line)
          end
          new factory
        end
      end
    end
  end
end

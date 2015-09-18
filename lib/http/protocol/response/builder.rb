module HTTP
  module Protocol
    class Response
      class Builder < Message::Builder
        def self.build
          factory = -> first_line do
            StatusLineParser.(first_line)
          end
          new factory
        end
      end
    end
  end
end

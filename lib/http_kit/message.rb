module HTTPKit
  class Message
    HEADER_REGEX = %r{^(?<header>[-\w]+): (?<value>.*?)\s*\r$}
  end
end

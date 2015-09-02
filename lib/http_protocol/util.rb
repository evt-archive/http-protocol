module HTTPProtocol
  module Util
    extend self

    def to_camel_case str
      str = "_#{str}"
      str.gsub! %r{[-_][a-zA-Z\d]} do |snake|
        snake.slice(1).upcase
      end
      str.gsub! '/', '::'
      str
    end

    def to_snake_case str
      str = str.gsub '::', '/'
      # Convert FOOBar => FooBar
      str.gsub! %r{[[:upper:]]{2,}} do |uppercase|
        bit = uppercase[0]
        bit << uppercase[1...-1].downcase
        bit << uppercase[-1]
        bit
      end
      # Convert FooBar => foo_bar
      str.gsub! %r{[[:lower:]][[:upper:]]+[[:lower:]]} do |camel|
        bit = camel[0]
        bit << '_'
        bit << camel[1..-1].downcase
      end
      str.downcase!
      str
    end
  end
end

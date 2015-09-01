require "forwardable"
require "time"

module HTTPKit
  autoload :Headers, "http_kit/headers"
  autoload :Request, "http_kit/request"
  autoload :Response, "http_kit/response"
  autoload :Util, "http_kit/util"

  def self.newline
    "\r\n".freeze
  end

  ProtocolError = Class.new StandardError
end

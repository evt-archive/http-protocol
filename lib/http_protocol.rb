require "forwardable"
require "time"

module HTTPProtocol
  autoload :Headers, "http_protocol/headers"
  autoload :Message, "http_protocol/message"
  autoload :Request, "http_protocol/request"
  autoload :Response, "http_protocol/response"
  autoload :Util, "http_protocol/util"

  Error = Class.new StandardError
end

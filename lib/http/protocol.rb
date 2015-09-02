require "forwardable"
require "time"

module HTTP
  module Protocol
    autoload :Headers, "http/protocol/headers"
    autoload :Message, "http/protocol/message"
    autoload :Request, "http/protocol/request"
    autoload :Response, "http/protocol/response"
    autoload :Util, "http/protocol/util"

    Error = Class.new StandardError
  end
end

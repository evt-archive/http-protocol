require_relative "../test_init"

require "json"
require "securerandom"
require "socket"
require "stringio"
require "time"

unless respond_to? :assert
  def assert(expression)
    fail "Assertion failed" unless expression
  end
end

unless respond_to? :logger
  def logger
    Telemetry::Logger.get self
  end
end

unless respond_to? :describe
  def describe(*, &blk)
    blk.()
  end
end

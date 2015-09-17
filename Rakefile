desc "Start HTTP server for testing"
task :test_server do
  lib_root = File.expand_path "../lib", __FILE__
  $LOAD_PATH << lib_root unless $LOAD_PATH.include? lib_root

  require "http/protocol"
  require "http/protocol/controls"

  trap "INT" do HTTP::Protocol::Controls::HTTPServer.stop end
  HTTP::Protocol::Controls::HTTPServer.start
end

lib_root = File.expand_path "../lib", __FILE__
$LOAD_PATH << lib_root unless $LOAD_PATH.include? lib_root

require "http_protocol"
require "http_protocol/controls"

desc "Start HTTP server for testing"
task :test_server do
  trap "INT" do HTTPProtocol::Controls::HTTPServer.stop end
  HTTPProtocol::Controls::HTTPServer.start
end

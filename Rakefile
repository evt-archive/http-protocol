lib_root = File.expand_path "../lib", __FILE__
$LOAD_PATH << lib_root unless $LOAD_PATH.include? lib_root

require "http_kit"
require "http_kit/controls"

desc "Start HTTP server for testing"
task :test_server do
  trap "INT" do HTTPKit::Controls::HTTPServer.stop end
  HTTPKit::Controls::HTTPServer.start
end

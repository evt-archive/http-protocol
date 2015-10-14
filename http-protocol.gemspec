Gem::Specification.new do |s|
  s.name = "http-protocol"
  s.version = '0.0.0'
  s.summary = "HTTP protocol library designed to facilitate custom HTTP clients"
  s.authors = ['']
  s.require_paths = ['lib']
  s.files = Dir.glob('{lib}/**/*')
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>= 2.2.3'

  s.add_runtime_dependency 'telemetry-logger'
end

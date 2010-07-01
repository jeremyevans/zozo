spec = Gem::Specification.new do |s|
  s.name = "zozo"
  s.version = "1.0.0"
  s.author = "Jeremy Evans"
  s.email = "code@jeremyevans.net"
  s.homepage = "http://github.com/jeremyevans/zozo"
  s.platform = Gem::Platform::RUBY
  s.summary = "Simple $LOAD_PATH management for ruby projects"
  s.files = %w"README.rdoc LICENSE bin/zozo spec/zozo_spec.rb"
  s.extra_rdoc_files = ["README.rdoc", "LICENSE", "bin/zozo"]
  s.rdoc_options += ["--quiet", "--line-numbers", "--inline-source", '--title', 'zozo: Simple $LOAD_PATH management for ruby projects', '--main', 'README.rdoc']
  s.test_files = %w"spec/zozo_spec.rb"
  s.has_rdoc = true
  s.require_path = "bin"
  s.bindir = 'bin'
  s.executables << 'zozo'
end

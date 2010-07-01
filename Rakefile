require 'rake'
require 'rake/clean'
require "spec/rake/spectask"
begin
  require "hanna/rdoctask"
rescue LoadError
  require "rake/rdoctask"
end

CLEAN.include %w"rdoc"

task :default => [:spec]
Spec::Rake::SpecTask.new("spec") do |t|
  t.spec_files = %w'spec/zozo_spec.rb'
end

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = "rdoc"
  rdoc.options += ["--quiet", "--line-numbers", "--inline-source"]
  rdoc.main = "README.rdoc"
  rdoc.title = "zozo: Simple $LOAD_PATH management for ruby projects"
  rdoc.rdoc_files.add ["README.rdoc", "LICENSE",  "bin/zozo"]
end

desc "Package zozo"
task :package do
  sh %{gem build zozo.gemspec}
end

desc "Install zozo"
task :install => [:package] do
  sh %{sudo gem install zozo-*.gem}
end

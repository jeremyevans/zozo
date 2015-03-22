require 'rake'
require 'rake/clean'

CLEAN.include %w"rdoc"

begin
  begin
    raise LoadError if ENV['RSPEC1']
    # RSpec 2
    require "rspec/core/rake_task"
    spec_class = RSpec::Core::RakeTask
    spec_files_meth = :pattern=
  rescue LoadError
    # RSpec 1
    require "spec/rake/spectask"
    spec_class = Spec::Rake::SpecTask
    spec_files_meth = :spec_files=
  end

  desc "Run specs"
  spec_class.new("spec") do |t|
    t.send(spec_files_meth, ["spec/zozo_spec.rb"])
  end
  task :default => [:spec]
rescue LoadError
  task :default do
    puts "Must install rspec to run the default task (which runs specs)"
  end
end

RDOC_OPTS = ["--quiet", "--line-numbers", "--inline-source"]
rdoc_task_class = begin
  require "rdoc/task"
  RDOC_OPTS.concat(['-f', 'hanna'])
  RDoc::Task
rescue LoadError
  require "rake/rdoctask"
  Rake::RDocTask
end

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = "rdoc"
  rdoc.options += RDOC_OPTS
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

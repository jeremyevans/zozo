#!/usr/bin/env spec

require 'rbconfig'
require 'fileutils'
require 'open3'
Dir.chdir(File.dirname(File.expand_path(__FILE__)))

RUBY = ENV['RUBY'] || "'#{File.join(RbConfig::CONFIG['bindir'], RbConfig::CONFIG['ruby_install_name'] + RbConfig::CONFIG['EXEEXT']).gsub("'", "'\\''")}'"

context "zozo" do
  after do
    FileUtils.rm_r('lib') if File.directory?('lib')
    FileUtils.rm_r('bin') if File.directory?('bin')
  end

  def run(args='test1')
    `#{RUBY} -I. #{File.join(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))), 'bin', 'zozo')} #{args}`
  end

  def run3(args='test1', &block)
    Open3.popen3("#{RUBY} -I. #{File.join(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))), 'bin', 'zozo')} #{args}", &block)
  end

  def ino(f)
    File.stat(f).ino
  end

  def should_be_same(f1, f2)
    File.read(f1).should == File.read(f2)
  end

  it "should create bin and lib directories with symbolic links by default" do
    run.should == ''
    File.file?('lib/a').should be_true
    File.symlink?('lib/a').should be_true
    should_be_same('lib/a', 'test1/a')
    File.directory?('lib/b').should be_true
    File.file?('lib/b/c').should be_true
    File.symlink?('lib/b/c').should be_true
    should_be_same('lib/b/c', 'test1/b/c')

    File.file?('bin/b1').should be_true
    File.symlink?('bin/b1').should be_true
    should_be_same('bin/b1', 'b/bin/b1')
    File.directory?('bin/d').should be_true
    File.file?('bin/d/b2').should be_true
    File.symlink?('bin/d/b2').should be_true
    should_be_same('bin/d/b2', 'b/bin/d/b2')
  end

  it "should print out help if -h option is used" do
    run('-h').should =~ /Usage: zozo/
  end

  it "should create bin and lib directories with hard links if the -H option is used" do
    run('-H test1').should == ''
    File.file?('lib/a').should be_true
    File.symlink?('lib/a').should be_false
    ino('lib/a').should == ino('test1/a')
    File.directory?('lib/b').should be_true
    File.file?('lib/b/c').should be_true
    File.symlink?('lib/b/c').should be_false
    ino('lib/b/c').should == ino('test1/b/c')

    File.file?('bin/b1').should be_true
    File.symlink?('bin/b1').should be_false
    ino('bin/b1').should == ino('b/bin/b1')
    File.directory?('bin/d').should be_true
    File.file?('bin/d/b2').should be_true
    File.symlink?('bin/d/b2').should be_false
    ino('bin/d/b2').should == ino('b/bin/d/b2')
  end

  it "should create bin and lib directories with file copies if the -c option is used" do
    run('-c test1').should == ''
    File.file?('lib/a').should be_true
    File.symlink?('lib/a').should be_false
    ino('lib/a').should_not == ino('test1/a')
    should_be_same('lib/a', 'test1/a')
    File.directory?('lib/b').should be_true
    File.file?('lib/b/c').should be_true
    File.symlink?('lib/b/c').should be_false
    ino('lib/b/c').should_not == ino('test1/b/c')
    should_be_same('lib/b/c', 'test1/b/c')

    File.file?('bin/b1').should be_true
    File.symlink?('bin/b1').should be_false
    ino('bin/b1').should_not == ino('b/bin/b1')
    should_be_same('bin/b1', 'b/bin/b1')
    File.directory?('bin/d').should be_true
    File.file?('bin/d/b2').should be_true
    File.symlink?('bin/d/b2').should be_false
    ino('bin/d/b2').should_not == ino('b/bin/d/b2')
    should_be_same('bin/d/b2', 'b/bin/d/b2')
  end

  it "should load files with load instead of require if the -L option is used" do
    run3('load_test') do |si, so, se|
      se.read.should =~ /load_test \(LoadError\)/
      so.read.should == ''
    end
    run('-L load_test').should == ''
    File.file?('lib/a').should be_true
    File.symlink?('lib/a').should be_true
    should_be_same('lib/a', 'test1/a')
    File.directory?('lib/b').should be_true
    File.file?('lib/b/c').should be_true
    File.symlink?('lib/b/c').should be_true
    should_be_same('lib/b/c', 'test1/b/c')

    File.file?('bin/b1').should be_true
    File.symlink?('bin/b1').should be_true
    should_be_same('bin/b1', 'b/bin/b1')
    File.directory?('bin/d').should be_true
    File.file?('bin/d/b2').should be_true
    File.symlink?('bin/d/b2').should be_true
    should_be_same('bin/d/b2', 'b/bin/d/b2')
  end

  it "should load rackup files with Rack::Builder instead of require if the -R option is used" do
    run3('test.ru') do |si, so, se|
      se.read.should =~ /test.ru \(LoadError\)/
      so.read.should == ''
    end
    run('-R test.ru').should == ''
    File.file?('lib/a').should be_true
    File.symlink?('lib/a').should be_true
    should_be_same('lib/a', 'test1/a')
    File.directory?('lib/b').should be_true
    File.file?('lib/b/c').should be_true
    File.symlink?('lib/b/c').should be_true
    should_be_same('lib/b/c', 'test1/b/c')

    File.file?('bin/b1').should be_true
    File.symlink?('bin/b1').should be_true
    should_be_same('bin/b1', 'b/bin/b1')
    File.directory?('bin/d').should be_true
    File.file?('bin/d/b2').should be_true
    File.symlink?('bin/d/b2').should be_true
    should_be_same('bin/d/b2', 'b/bin/d/b2')
  end

  it "should not make any file system modifications if -n option is used" do
    run('-n test1').should == ''
    File.exist?('lib').should be_false
    File.exist?('bin').should be_false
  end

  it "should force file system modifications over existing files if -f option is used" do
    run.should == ''
    run3 do |si, so, se|
      se.read.should =~ %r{File exists.*\(Errno::EEXIST\)}
      so.read.should == ''
    end
    run('-f test1').should == ''
    File.file?('lib/a').should be_true
    File.symlink?('lib/a').should be_true
    should_be_same('lib/a', 'test1/a')
    File.directory?('lib/b').should be_true
    File.file?('lib/b/c').should be_true
    File.symlink?('lib/b/c').should be_true
    should_be_same('lib/b/c', 'test1/b/c')

    File.file?('bin/b1').should be_true
    File.symlink?('bin/b1').should be_true
    should_be_same('bin/b1', 'b/bin/b1')
    File.directory?('bin/d').should be_true
    File.file?('bin/d/b2').should be_true
    File.symlink?('bin/d/b2').should be_true
    should_be_same('bin/d/b2', 'b/bin/d/b2')
  end

  it "should log all file system modifications to stderr if -v option is used" do
    run3('-v test1') do |si, so, se|
      se.read.split("\n").should == ["mkdir lib", "ln -s /data/code/zozo/spec/test1/a lib/a", "mkdir lib/b", "ln -s /data/code/zozo/spec/test1/b/c lib/b/c", "mkdir bin", "ln -s /data/code/zozo/spec/b/bin/b1 bin/b1", "mkdir bin/d", "ln -s /data/code/zozo/spec/b/bin/d/b2 bin/d/b2", "Writing lib/rubygems.rb", "Writing lib/ubygems.rb", "Writing lib/bundler.rb"]
      se.read.should == ''
    end
    File.file?('lib/a').should be_true
    File.symlink?('lib/a').should be_true
    should_be_same('lib/a', 'test1/a')
    File.directory?('lib/b').should be_true
    File.file?('lib/b/c').should be_true
    File.symlink?('lib/b/c').should be_true
    should_be_same('lib/b/c', 'test1/b/c')

    File.file?('bin/b1').should be_true
    File.symlink?('bin/b1').should be_true
    should_be_same('bin/b1', 'b/bin/b1')
    File.directory?('bin/d').should be_true
    File.file?('bin/d/b2').should be_true
    File.symlink?('bin/d/b2').should be_true
    should_be_same('bin/d/b2', 'b/bin/d/b2')
  end

  it "should handle rubygems' gem method correctly" do
    run
    `ruby -I lib test_rubygems.rb`.should == 'no_error'
  end

  it "should handle requiring rubygems as ubygems" do
    run
    `ruby -I lib test_ubygems.rb`.should == 'no_error'
  end

  it "should handle bundler's Bundler.setup method correctly" do
    run
    `ruby -I lib test_bundler.rb`.should == 'no_error'
  end

  it "should raise an error on file/directory overlap, with directory after file" do
    run3('test2') do |si, so, se|
      se.read.should =~ %r{File/directory overlap \(file: .*/zozo/spec/test2/b, directory: .*/zozo/spec/test1/b\) \(StandardError\)}
      so.read.should == ''
    end
  end

  it "should raise an error on file/directory overlap, with file after directory" do
    run3('test3') do |si, so, se|
      se.read.should =~ %r{File/directory overlap \(file: .*/zozo/spec/test2/b, directory: b\) \(StandardError\)}
      so.read.should == ''
    end
  end

  it "should define ZOZO environment variable when running under zozo" do
    run('test_zozo').should == 'no_error'
  end
end

context "zozo -b and -l arguments" do
  after do
    FileUtils.rm_r('li')
    FileUtils.rm_r('bi')
  end

  def should_be_same(f1, f2)
    File.read(f1).should == File.read(f2)
  end

  it "should create bin and lib directories with given names" do
    `#{RUBY} -I. #{File.join(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))), 'bin', 'zozo')} -b bi -l li test1`
    File.file?('li/a').should be_true
    File.symlink?('li/a').should be_true
    should_be_same('li/a', 'test1/a')
    File.directory?('li/b').should be_true
    File.file?('li/b/c').should be_true
    File.symlink?('li/b/c').should be_true
    should_be_same('li/b/c', 'test1/b/c')

    File.file?('bi/b1').should be_true
    File.symlink?('bi/b1').should be_true
    should_be_same('bi/b1', 'b/bin/b1')
    File.directory?('bi/d').should be_true
    File.file?('bi/d/b2').should be_true
    File.symlink?('bi/d/b2').should be_true
    should_be_same('bi/d/b2', 'b/bin/d/b2')
  end
end

# -*- coding: utf-8 -*-
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

task :default=>:test

task :test do
  Dir['spec/case/**/*'].each {|test|
    sh "ruby #{test}" if test =~ /(_test\.rb)$/
  }
end

desc "start test for given file"
task :test_file, [:file] do |t, args|
  sh "ruby spec/case/#{args.file}_test.rb"
end

desc "创建gemspec文件"
task :gemspec do
  spec = Gem::Specification.new do |s|
    s.name = %{zeng}
    s.version = '0.0.2'
    s.summary = 'Zeng -- a data mapper tool for nosql database'
    s.homepage = 'https://github.com/baya/zeng'
    s.description = <<-EOF
      Zeng(罾) is a fishing tool， it is target to capture data in nosql database。
    EOF
    s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
    s.email = ["kayak.jiang@gmail.com"]
    s.authors = "Guimin Jiang"
    s.files = Dir["./**/*"].delete_if {|path| path =~ /.gem$/}
    s.require_paths = ["lib"]
    s.add_dependency(%q<json>)
  end

  File.open("zeng.gemspec", "w") {|f| f << spec.to_ruby }
end


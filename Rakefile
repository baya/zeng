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
		s.name = %{cutekv}
		s.version = '0.0.1'
		s.description = 'CuteKV -- based at Ruby for object-key/value map'
		s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=

		s.email = ["kayak.jiang@gmail.com"]
		s.authors = "Guimin Jiang"
		s.files = Dir["./**/*"].delete_if {|path| path =~ /.gem$/}
		s.require_paths = ["lib"]
		s.required_ruby_version = Gem::Requirement.new(">= 1.8.6")
		s.rubygems_version = %q{1.3.4}
		s.add_dependency(%q<ffi>)
	end

	File.open("cutekv.gemspec", "w") {|f| f << spec.to_ruby }
end


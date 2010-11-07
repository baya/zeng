require 'pathname'

require File.join(File.dirname(__FILE__), '..','lib','cutekv')

require 'test/unit'

def uses_mocha(description)
	require 'rubygems'
	require 'mocha'
	yield
rescue LoadError
	$stderr.puts "Skipping #{description} tests. `gem install mocha` and try again."
end

module ModelDivider

	def self.divide(*models)
		models.size > 1 ? models.each {|model| divide(model)} : require(locate(models))
	end

	protected
	def self.locate(model)
		File.join(File.dirname(__FILE__), "model", "#{model.to_s}")
	end

end




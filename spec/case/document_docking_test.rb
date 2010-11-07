require File.join(File.dirname(__FILE__),'..','helper')

module Validation
	def self.included(base)
		base.extend ClassMethods
		base.send :include, InstanceMethods
	end

	module InstanceMethods
		def valid
			"instance valid"
		end
	end

	module ClassMethods
		def valid
			"class valid"
		end
	end
end

module Observer
	def self.included(base)
		base.extend ClassMethods
		base.send :include, InstanceMethods
	end
	module InstanceMethods
		def observe
			"instance observe"
		end
	end

	module ClassMethods
		def observe
			"class observe"
		end
	end

end

ModelDivider.divide "User", "Icon", "Project", "Book"


class DockingTest < Test::Unit::TestCase

	def setup
		@jim = User.create(:name=>"jim")
		@icon = Icon.create(:name=>"flower")
		@project = Project.create(:name=>"nonobo")
		@book = Book.create(:name=>"ruby")
	end

	def test_docking_module
    assert CuteKV::Document.respond_to?(:docking)
		respond_test(false)
		CuteKV::Document::docking(Validation)
		CuteKV::Document::docking(Observer)
		clients = CuteKV::Document::clients
		CuteKV::Document::docking(Validation)
		CuteKV::Document::docking(Observer)
		assert_equal CuteKV::Document::clients, clients
		respond_test(true)

		assert_equal @jim.valid, "instance valid"
		assert_equal @icon.valid, "instance valid"
		assert_equal @project.valid, "instance valid"
		assert_equal @book.valid, "instance valid"
		assert_equal User.valid, "class valid"
		assert_equal Icon.valid, "class valid"
		assert_equal Project.valid, "class valid"
		assert_equal Book.valid, "class valid"
		assert_equal @jim.observe, "instance observe"
		assert_equal @icon.observe, "instance observe"
		assert_equal @project.observe, "instance observe"
		assert_equal @book.observe, "instance observe"
		assert_equal User.observe, "class observe"
		assert_equal Icon.observe, "class observe"
		assert_equal Project.observe, "class observe"
		assert_equal Book.observe, "class observe"
	end

	def respond_test(opt=false)
		assert_equal User.respond_to?(:observe),opt 
		assert_equal User.respond_to?(:valid), opt
		assert_equal Icon.respond_to?(:observe), opt
		assert_equal Icon.respond_to?(:valid), opt
		assert_equal Project.respond_to?(:observe), opt
		assert_equal Project.respond_to?(:valid), opt
		assert_equal Book.respond_to?(:observe), opt
		assert_equal Book.respond_to?(:valid), opt
		assert_equal @jim.respond_to?(:observe), opt
		assert_equal @jim.respond_to?(:valid), opt
		assert_equal @icon.respond_to?(:observe), opt
		assert_equal @icon.respond_to?(:valid), opt
		assert_equal @project.respond_to?(:observe), opt
		assert_equal @project.respond_to?(:valid), opt
		assert_equal @book.respond_to?(:observe), opt
		assert_equal @book.respond_to?(:valid), opt
	end

end



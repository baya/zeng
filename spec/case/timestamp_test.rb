require File.join(File.dirname(__FILE__),'..','helper')
ModelDivider.divide "User", "Icon", "Project", "Book"
User.add_timestamps
Icon.add_timestamps
Project.add_timestamps

class TimestampTest < Test::Unit::TestCase
	def setup
		User.clear
		Icon.clear
		Project.clear
		Book.clear
		@jim = User.create(:name=>"jim")
		@icon = Icon.create(:name=>"flower")
		@nonobo = Project.create(:name=>"nonobo")
		@ruby = Book.create(:name=>"Ruby")
	end

	def test_time_zone
    assert_equal User.default_timezone, :utc
    assert_equal Icon.default_timezone, :utc
    assert_equal Project.default_timezone, :utc
	end

	def test_no_timestamp
		assert_equal @ruby.respond_to?(:created_at), false
		assert_equal @ruby.respond_to?(:updated_at), false
		Book.add_timestamps
		assert_equal @ruby.respond_to?(:created_at), true
		assert_equal @ruby.respond_to?(:updated_at), true
		@ruby.save
		assert_equal @ruby.created_at.class, DateTime
		assert_equal @ruby.updated_at.class, DateTime
	end

	def test_created_at
		assert_equal @jim.created_at.class, DateTime
		assert_equal @icon.created_at.class, DateTime
		assert_equal @nonobo.created_at.class, DateTime
		jim_created_at = @jim.created_at
		jim_updated_at = @jim.updated_at
		object_time_test(@jim)
		object_time_test(@icon)
		object_time_test(@nonobo)
	end


	def object_time_test(object)
		created_at = object.send :created_at
		updated_at = object.send :updated_at
		assert_equal created_at, updated_at
		object.save
		sleep 2
		updated_at2 = object.send :updated_at
		created_at2 = object.send :created_at
		assert (updated_at2 > updated_at)
		assert_equal created_at2,  updated_at
		assert_equal created_at2,  created_at
	end

	def test_no_timestamps
	end

end


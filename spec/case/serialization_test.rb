require File.join(File.dirname(__FILE__),'..','helper')
ModelDivider.divide "User"
User.assign(:name, :email, :gender=>"male", :age=>25)
User.add_timestamps

CuteKV::Associations::map(User=>:friends)
CuteKV::Associations::map(User=>[:wife,:husband])

class SerializationTest < Test::Unit::TestCase
	def setup
		User.clear
		@jim = User.create(:name=>"jim")
		@jack = User.create(:name=>"jack")
		@kame = User.create(:name=>"kame")
		@nacy = User.create(:name=>"nancy")
		@aaron = User.create(:name=>"aaron")
		@rita = User.create(:name=>"rita")
	end

	def test_to_json
		jim = User.new(:name=>"jim")
		assert jim.to_json =~ /"name":"jim"/
	end


	def test_to_json_include_has_many

		@jim.friends << @jack
		@jim.friends << @kame
		@jim.friends << @nancy

		assert_equal @jim.to_json(:include=>:friends).grep(/kame/).empty?,false
		assert_equal @kame.to_json(:include=>:friends).grep(/jim/).empty?,false
		assert_equal @jack.to_json(:include=>:friends).grep(/jim/).empty?,false
		assert_equal @jim.to_json(:only=>:name),{"name"=>@jim.name}.to_json
		assert_equal @jim.to_json(:except=>[:name,:email] ),{"gender"=>@jim.gender, "age"=>@jim.age, "id"=>@jim.id, "created_at"=>@jim.created_at, "updated_at"=>@jim.updated_at}.to_json
	end

	def test_array_to_json_include_has_many_this_test_has_some_problem
		@jim.friends << @kame
		@jim.friends << @jack
		@jack.friends << @kame
		assert_nothing_raised do
			@jim.friends.to_json(:include=>:friends)
		end
	end

	def test_to_json_include_has_one

		@aaron.wife = @rita

		assert_equal @aaron.to_json(:include=>:wife).grep(/rita/).empty?,false
	end




	def test_to_xml
		assert @aaron.to_xml
	end

	def test_to_xml_include_has_many
		@jim.friends << @jack
		@jim.friends << @kame
		assert_equal @jim.to_xml(:include=>:friends).grep(/jack/).empty?,false
		assert_equal @jim.to_xml(:include=>:friends).grep(/kame/).empty?,false
		assert_equal @jack.to_xml(:include=>:friends).grep(/jim/).empty?,false
		assert_equal @kame.to_xml(:include=>:friends).grep(/jim/).empty?,false
	end

	def test_to_xml_include_has_one

		@aaron.wife = @rita
		assert_equal @aaron.to_xml(:include=>:wife).grep(/rita/).empty?,false
		assert_equal @rita.to_xml(:include=>:husband).grep(/rita/).empty?,false
	end

end

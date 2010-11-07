require File.join(File.dirname(__FILE__),'..','helper')
ModelDivider.divide "User", "Icon", "Project"

class IndexerTest < Test::Unit::TestCase

	def setup
		User.clear
		Project.clear
		@aaron = User.create(:name=>'aaron', :email=>'aaron@nonobo.com')
		@jim = User.create(:name=>'jim', :email=>'jim@nonobo.com')
		@jim_d = User.create(:name=>'jim', :email=>'aaron@nonobo.com')
		@jack = User.create(:name=>'jack', :email=>'jack@nonobo.com')
		@kame = User.create(:name=>'kame', :email=>'kame@nonobo.com')
		@nonobo = Project.create(:name=>"nonobo")
	end

	def test_indexer_base
	  assert CuteKV::Indexer::map(User=>['name', 'email'])
	  assert CuteKV::Indexer::map(Project=>'created_at')
		assert User.indexes == []
		User.indexes << @aaron
		User.indexes << @jim
		User.indexes << @jim_d
		User.indexes << @jack
		User.indexes << @jim
		User.indexes << @aaron
		assert User.indexes.size==4
		assert User.indexes.include?([@aaron.id,{"id"=>@aaron.id, "name"=>@aaron.name, "email"=>@aaron.email}])
		assert User.indexes.include?([@jim.id,{"id"=>@jim.id, "name"=>@jim.name, "email"=>@jim.email}])
		assert User.indexes.include?([@jim_d.id,{"id"=>@jim_d.id, "name"=>@jim_d.name, "email"=>@jim_d.email}])
		assert User.indexes.include?([@jack.id,{"id"=>@jack.id, "name"=>@jack.name, "email"=>@jack.email}])
		assert User.respond_to?(:find_all_by_email)
		assert User.find_all_by_name("aaron")[0].name=="aaron"
		assert User.find_all_by_name("jim").size==2
		assert_equal User.find_all_by_email("aaron@nonobo.com").size,2
		assert_equal User.find_all_by_email("aaron@nonobo.com")[0].email, "aaron@nonobo.com"
	end


end

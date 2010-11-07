require File.join(File.dirname(__FILE__),'..','helper')
ModelDivider.divide "User", "Account"

class DocumentTest < Test::Unit::TestCase

	def setup
		User.backend_configure(:TT, '127.0.0.1:1985')
		Account.backend_configure(:TT, :host=>'127.0.0.1', "port"=>1984)
		User.assign(:name, :age=>25, :gender=>"male")
		Account.assign(:email, :password, :country=>"China")
		User.clear
		Account.clear
		@jim = User.new(:name=>"jim")
		@a_jim = Account.new(:email=>"jim@nonobo.com")
		@attrs_group = [{:name=>"jim"}, {:name=>"jack"}, {:name=>"nancy"}, {:name=>"kame"}]
	end

	def test_assign_attributes_to_persistence
		assert User.assign(:name, :age=>25, :gender=>[])
		assert Account.assign(:email, :password, :country=>{})
		@jim = User.new(:name=>"jim")
		assert_equal @jim.name, "jim"
		assert_equal @jim.age, 25
		assert_equal @jim.gender, []
		@jack = User.new(:name=>"jack"){|u| u.gender="female"; u.age=36}
		assert_equal @jack.name, "jack"
		assert_equal @jack.age, 36
		assert_equal @jack.gender, "female"
		@account_jim = Account.new(:email=>"jim@nonobo.com")
		assert_equal @account_jim.email, "jim@nonobo.com"
		assert_equal @account_jim.country, {}
	end

	def test_set_backend
		assert User.backend_configure(:TT, '127.0.0.1:1985')
		assert Account.backend_configure(:TT, :host=>'127.0.0.1', "port"=>1984)
		assert User.clear
		assert Account.clear
	end

	def test_persistence_assigned_attributes_and_id
		assert @jim.save
		assert @a_jim.save
		jim = User.find(@jim.id)
		a_jim =  Account.find(@a_jim.id)
		assert_equal jim.id, @jim.id
		assert_equal jim.name, @jim.name
		assert_equal jim.gender, @jim.gender
		jim.age = 30
		jim.save
		j = User.find(@jim.id)
		assert_equal j.id, @jim.id
		assert_equal j.age, 30
	end

	def test_create_single_object
		jack = User.create(:name=>"jack")
		assert_equal jack.name, "jack"
		assert_equal jack.gender, "male"
		assert_equal jack.age, 25
		jim = User.create(:name=>'jim') {|u| u.age=55; u.gender="female" }
		assert_equal jim.age, 55
		assert_equal jim.gender, 'female'
		jm = User.find(jim.id)
		assert_equal jm.id, jim.id
		assert_equal jm.age, 55
		assert_equal jm.gender, 'female'
	end


	def test_destroy_object
		jim = User.create(:name=>"jim")
		a_jim = Account.create(:email=>"jim@nonobo.com")
		assert_equal jim.name, "jim"
		assert_equal a_jim.email, "jim@nonobo.com"
		assert User.destroy(jim)
		assert_equal User.destroy(a_jim), nil
		jm = User.find(jim.id)
		assert jm.nil?
	end

	def test_update_object
		jim = User.create(:name=>'jim')
		assert_equal jim.age, 25
		assert_equal jim.gender, 'male'
		jim.update(:age=>52, :gender=>'female')
		assert_equal jim.age, 52 
		assert_equal jim.gender, 'female'
		jm = User.find(jim.id)
		assert_equal jm.age, 25
		assert_equal jm.gender, 'male'
		jim.save
		jm = User.find(jim.id)
		assert_equal jm.age, 52
		assert_equal jm.gender, 'female'
	end

	def test_reload_object
		jim = User.new(:name=>'jim')
		jim_id = jim.id
		assert jim.name == 'jim'
		assert jim.age == 25
		assert jim.reload.nil?
		jim.save
		jm = User.find(jim.id)
		jm.age = 59
		jm.save
		assert_equal jim.age, 25
		assert_equal jm.age, 59
		assert jim.reload
		assert_equal jim.age, 59
		assert_equal jim.id, jim_id
	end

	def test_class_method_save
		jim = User.new(:name=>"jim")
		a_jim = Account.new(:email=>"jim@nonobo.com")
		assert_equal jim.age, 25
		assert jim.id
		assert User.find(jim.id).nil?
		assert User.save(jim)
		assert User.find(jim.id)
		assert User.save("jim").nil?
		assert User.save(a_jim).nil?
	end

	def test_class_method_update
		jim = User.new(:name=>"jim")
		a_jim = Account.new(:email=>"jim@nonobo.com")
		assert User.update(jim, :age=>36, :gender=>'female')
		assert_equal jim.age, 36
		assert_equal jim.gender, 'female'
		assert User.update(jim, :age=>45)
		assert_equal jim.age, 45
		assert User.update(jim)
		assert_equal jim.age, 45
		assert_equal jim.gender, 'female'
		assert User.update(a_jim).nil?
	end

	def test_class_reload
		jim = User.new(:name=>"jim")
		a_jim = Account.new(:email=>"jim@nonobo.com")
		assert_equal jim.age, 25
		assert_equal jim.gender, 'male'
		jim.update(:age=>58, :gender=>'female')
		jim.save
		jim_id = jim.id
		assert User.reload(jim)
		assert_equal jim.id, jim_id
		assert jim.age, 58
		assert jim.gender, 'female'
		assert User.reload(a_jim).nil?
	end

	def test_select_serializers
		assert User.select_serializer(:json)
		assert Account.select_serializer(:marshal)
		assert User.serializer_type=="json"
		assert Account.serializer_type=="marshal"
		a_jim = Account.create(:email=>"jim@nonobo.com")
		a_j = Account.find(a_jim.id)
		assert_equal a_jim.email, "jim@nonobo.com"
		assert_equal a_j.email, "jim@nonobo.com"
		assert Account.select_serializer(:marshal)
		assert Account.serializer_type=="marshal"
		a_jack = Account.create(:email=>"jack@nonobo.com")
		a_jk = Account.find(a_jack.id)
		assert_equal a_jk.email, "jack@nonobo.com"
		assert_equal a_jk.id, a_jack.id
	end

	def test_backend_configurations
		assert User.backend_configure(:TT, '127.0.0.1:1984')
		assert Account.backend_configure(:TT, '127.0.0.1:1985')
    assert_equal User.backend_configurations, {:adapter=>:TT, :host=>'127.0.0.1', :port=>1984}
    assert_equal Account.backend_configurations, {:adapter=>:TT, :host=>'127.0.0.1', :port=>1985}
	end

	def test_fresh_object
		lili = User.new(:name=>'lili')
	end

end

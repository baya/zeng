require File.join(File.dirname(__FILE__),'..','helper')
AA = CuteKV

ModelDivider.divide "User", "Icon", "Project", "Book"
Project.select_serializer(:marshal)

class RubymapTest < Test::Unit::TestCase

	def setup
		clear_database
		@aaron = User.create(:name=>'aaron', :email=>'aaron@nonobo.com')
		@rita = User.create(:name=>'rita')
		@jack = User.create(:name=>'jack', :email=>'jack@nonobo.com')
		@icon = Icon.create(:name=>"aaron.jpg", :path=>'/tmp/aaron.jpg')
		@icon2 = Icon.create(:name=>"jack.jpg", :path=>'/tmp/jack.jpg')
		@book = Book.create(:name=>"Deep hole")
		@book2 = Book.create(:name=>"css")
		@book3 = Book.create(:name=>"ruby on rails")
		@project_nonobo = Project.create(:name=>"无书网")
		@project_forum = Project.create(:name=>"多论坛")
	end

	def test_relations_by_self_friends_friends
		CuteKV::Associations::map(User=>:friends)
		assert_equal @jack.friends.size, 0
		assert_equal @aaron.friends.size, 0
		@jack.friends << @aaron 
		jack = User.find(@jack.id)
		assert_equal jack.friends[0].id, @aaron.id
		aaron = User.find(@aaron.id)
		assert_equal aaron.friends[0].id, jack.id
	end

	def test_relations_by_self_copy_icon
		CuteKV::Associations::map(Icon=>:copy)
		assert @icon.copy.nil?
		@icon.copy = @icon2
		icon = Icon.find(@icon.id)
		icon2 = Icon.find(@icon2.id)
		assert_equal icon.copy.id, @icon2.id
		assert_equal icon2.copy.id, @icon.id
	end

	def test_relations_husband_and_wife
		CuteKV::Associations::map(User=>[:wife, :husband])
		assert @aaron.wife.nil?
		assert @rita.husband.nil?
    @aaron.wife = @rita
		aaron = User.find(@aaron.id)
		rita = User.find(@rita.id)
		assert_equal aaron.wife.id, rita.id
		assert_equal rita.husband.id, aaron.id
	end

	def test_relaions_map_one_to_many
		AA::Associations.map(Book=>:owner, User=>:books)
		assert_equal @jack.books.size, 0
		assert_equal @aaron.books.size, 0
		@jack.books << @book
		@jack.books << @book2
		@jack.books << @book3
		jack = User.find(@jack.id)
		assert_equal @book.owner.id, @jack.id
		assert_equal @book2.owner.id, @jack.id
		assert_equal @book3.owner.id, @jack.id
		book_ids = @jack.books.map(&:id) 
		assert book_ids.include?(@book.id)
		assert book_ids.include?(@book2.id)
		assert book_ids.include?(@book3.id)
		@book.owner = @aaron
		assert_equal @book.owner.id, @aaron.id
		assert_equal @aaron.books.size, 1
		aaron = User.find(@aaron.id)
		assert aaron.books.map(&:id).include?(@book.id)
		assert_equal @jack.books.size, 2
		assert !@jack.books.map(&:id).include?(@book.id)
		@book2.owner = @aaron
		assert_equal @aaron.books.size, 2
		assert @aaron.books.map(&:id).include?(@book2.id)
		assert_equal @jack.books.size, 1
		assert !@jack.books.map(&:id).include?(@book2.id)

	end


	def test_relations_map_one_to_one
	  AA::Associations.map(User=>:icon, Icon=>:user)
		user_icon_test
	end

	def test_relations_map_one_to_one_set_singular
		AA::Associations.map(User=>:icons, Icon=>:users, :singular=>[:icons, :users])
		users_icons_test
	end

	def test_relations_map_one_to_many_set_singular_plural
		AA::Associations.map(Book=>:owner, User=>:books, :singular=>:owner, :plural=>:books)
		owner_books_test
	end

	def test_relations_map_many_to_many_set_plural
		AA::Associations.map(User=>:project, Project=>:member, :plural=>[:project, :member])
		member_project_test
	end

	def test_relations_map_one_to_many
		AA::Associations.map(Book=>:owner, User=>:books)
		owner_books_test
	end

	def test_relations_map_many_to_many
		AA::Associations.map(User=>:projects, Project=>:members)
		members_projects_test
	end

	def test_relations_map_many_to_many_set_plural
		AA::Associations.map(User=>:projects, Project=>:members, :plural=>[:projects, :members])
		members_projects_test
	end

	def owner_books_test
		assert_equal @aaron.books.size, 0
		assert_equal @book.owner, nil
		@aaron.books << @book
		aaron = User.find(@aaron.id)
		assert_equal @aaron.books.size, 1
		assert_equal aaron.books.size, 1
		assert_equal aaron.books[0].id, @book.id
		assert_equal @book.owner.id, aaron.id
		book = Book.find(@book.id)
		assert_equal book.owner.id, aaron.id
		aaron.books.remove(book)
		assert_equal aaron.books.size, 0
		assert_equal book.owner, nil
	end

	def user_icon_test
		assert @aaron.respond_to?(:icon=)
		@aaron.icon = @icon
		aaron = User.find(@aaron.id)
    assert_equal aaron.icon.id, @icon.id
    assert_equal aaron.icon.path, @icon.path
    assert_equal aaron.icon.name, @icon.name
		assert_equal @icon.user.id, aaron.id
		@aaron.icon.remove(@icon)
		assert @aaron.icon.nil?
		assert @icon.user.nil?
		@aaron.icon = @icon
		aaron = User.find(@aaron.id)
		assert_equal aaron.icon.id, @icon.id
		assert_equal @icon.user.id, aaron.id
		@aaron.icon = @icon2
		assert @icon.user.nil?
		assert_equal @icon2.user.id, aaron.id
		@icon2.user = @jack
		assert @aaron.icon.nil?
	end

	def users_icons_test
		assert @aaron.respond_to?(:icons=)
		@aaron.icons = @icon
		aaron = User.find(@aaron.id)
    assert_equal aaron.icons.id, @icon.id
		assert_equal @icon.users.id, aaron.id
		assert_equal @icon.users.name, aaron.name
	end

	def member_project_test
		assert_equal @aaron.project.size, 0
		assert_equal @project_nonobo.member.size, 0
		@aaron.project << @project_nonobo
		assert_equal @aaron.project.size, 1
		assert_equal @project_nonobo.member.size, 1
		aaron = User.find(@aaron.id)
		project = aaron.project.last
		member = @project_nonobo.member.last
		assert_equal member.id, aaron.id
		assert_equal project.id, @project_nonobo.id
	end

	def members_projects_test
		assert_equal @aaron.projects.size, 0
		assert_equal @project_nonobo.members.size, 0
		@aaron.projects << @project_nonobo
		assert_equal @aaron.projects.size, 1
		assert_equal @project_nonobo.members.size, 1
		aaron = User.find(@aaron.id)
		project = aaron.projects.last
		member = @project_nonobo.members.last
		assert_equal member.id, aaron.id
		assert_equal project.id, @project_nonobo.id
		aaron.projects.remove(@project_nonobo)
		assert_equal @project_nonobo.members.size, 0
		assert_equal @aaron.projects.size, 0
		@aaron.projects << @project_nonobo
		@aaron.projects << @project_forum
		aaron = User.find(@aaron.id)
		assert_equal aaron.projects.size, 2
		nonobo = Project.find(@project_nonobo.id)
		forum = Project.find(@project_forum.id)
		assert_equal nonobo.members.size, 1
		assert_equal forum.members.size, 1
		assert_equal nonobo.members[0].id, aaron.id
		assert_equal forum.members[0].id, aaron.id
		aaron.projects.remove(nonobo)
		aaron = User.find(@aaron.id)
		assert_equal aaron.projects.size, 1
		assert_equal nonobo.members.size, 0
		forum.members.remove(aaron)
		assert_equal aaron.projects.size, 0
		assert_equal forum.members.size, 0
	end

	def test_robust_of_many_to_many
		AA::Associations.map(User=>:projects, Project=>:members)
		robust_many_to_many_test
	end

	def robust_many_to_many_test
		@aaron.projects << "aadd"
		@aaron.projects << @jack
		@aaron.projects.remove("bbbbbb")
		@aaron.projects.remove(@jack)
		assert @aaron.projects.empty?
		@aaron.projects << @project_nonobo
		assert_equal @aaron.projects.size, 1
		assert @project_nonobo.destroy
		assert_equal @aaron.projects.size, 0
	end

	def test_Associations_map_from_yml
		yml_path = "#{File.dirname(__FILE__)}/../asso.yml"
		assert AA::Associations.map(yml_path)
		robust_many_to_many_test
		setup
	  members_projects_test
		setup
		user_icon_test
		setup
		owner_books_test
		setup
		project_master_test
	end

  def project_master_test	
		assert @jack.projects.size==0
		@jack.projects << @project_nonobo
		assert_equal @jack.projects.size, 1
		assert @project_nonobo.master.nil?
		@project_nonobo.master = @aaron
		assert_equal @aaron.project.id, @project_nonobo.id
		assert_equal @aaron.projects.size, 0
		assert_equal @project_nonobo.master.id, @aaron.id
	end

	def test_Associations_map_from_yml_sin_plural
		yml_path = "#{File.dirname(__FILE__)}/../asso_sin_plural.yml"
		assert AA::Associations.map(yml_path)
		robust_many_to_many_test
		setup
	  members_projects_test
		setup
		users_icons_test
		setup
		owner_book_test
		setup
		husband_wife_test
	end

	def husband_wife_test
		assert @aaron.wife.nil?
		assert @rita.husband.nil?
		@aaron.wife = @rita
		aaron = User.find(@aaron.id)
		assert_equal aaron.wife.id, @rita.id
		rita = User.find(@rita.id)
		assert_equal @aaron.wife.id, rita.id
		@lucy = User.create(:name=>"lucy")
		assert @lucy.husband.nil?
		@aaron.wife = @lucy
		assert_equal @aaron.wife.name, "lucy"
		assert_equal @aaron.wife.id, @lucy.id
		assert @rita.husband.nil?
		assert @lucy.husband.id==@aaron.id
	end


	def clear_database
		User.clear
		Icon.clear
		Project.clear
		Book.clear
	end

	def owner_book_test
		#User.select_serializer(:marshal)
		#Book.select_serializer(:json)
		assert_equal @aaron.book.size, 0
		assert_equal @book.owner, nil
		@aaron.book << @book
		aaron = User.find(@aaron.id)
		assert_equal @aaron.book.size, 1
		assert_equal aaron.book.size, 1
		assert_equal aaron.book[0].id, @book.id
		assert_equal @book.owner.id, aaron.id
		book = Book.find(@book.id)
		assert_equal book.owner.id, aaron.id
		aaron.book.remove(book)
		assert_equal aaron.book.size, 0
		assert_equal book.owner, nil
	end

end

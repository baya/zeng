require File.join(File.dirname(__FILE__),'..','helper')
ModelDivider.divide "User", "Account", "Project"
CuteKV::Document::docking(CuteKV::Validations)

class ValidationsTest < Test::Unit::TestCase

	def setup
		User.clear
		Account.clear
		Project.clear
	end

	def test_validates
		assert User.respond_to?(:validate)
		assert Account.respond_to?(:validate)
		assert Project.respond_to?(:validate)
	end

	def test_validates_presences
		User.class_eval {
			validate :name_presences

			def name_presences
				self.errors.add(:name, "name not blank") if self.name.blank?
			end
		}

		@wumin = User.create()
		assert @wumin.save.nil?
		assert User.find(@wumin.id).nil?
		assert_equal @wumin.errors.on(:name), "name not blank"

	end

	def test_validates_uniq
		CuteKV::Indexer::map(Account=>:email)
		Account.class_eval {
			validate :account_should_uniq

			def account_should_uniq
			  a = Account.find_all_by_email(self.email).first
				self.errors.add(:email, "this email has been registered") if a && a.id != self.id
			end
		}
		@jim = Account.new(:name=>'jim', :email=>'jim@nonobo.com')
		assert @jim.save
		Account.indexes << @jim
		assert @jim.save
		@jack = Account.new(:name=>'jack', :email=>'jim@nonobo.com')
		assert @jack.save.nil?
		assert @jack.errors_message_on(:email) == "this email has been registered"
		assert Account.find(@jack.id).nil?
	end

	def test_validates_length
    Project.class_eval {
			validate :project_name_should_long_than_8

			def project_name_should_long_than_8
				errors.add(:name, "project name is too short") if self.name.length < 8
			end
		}
		nonobo_book = Project.create(:name=>"nonobo book")
		assert nonobo_book.save
		assert Project.find(nonobo_book.id)
		nonobo = Project.create(:name=>"nonobo")
		assert nonobo.save.nil?
		assert Project.find(nonobo.id).nil?
		assert_equal nonobo.errors_message_on(:name), "project name is too short"
	end

end



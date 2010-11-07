require File.join(File.dirname(__FILE__),'..','helper')
ModelDivider.divide "User", "Icon", "Friend", "Project"

class Symmetry
	attr_reader :assos
  
	def initialize(asso={})
    @asso_string = parse(asso)
		@assos = @asso_string.split("#")
	end

	def mirror(object)
		m_o = @assos[@assos.size - 1 - @assos.index(object.to_s)]
    m_o = m_o.constantize if object.is_a? Class 
		m_o = m_o.to_sym if object.is_a? Symbol
		m_o
	end

	def each
		asso =  [[@assos[0].constantize, @assos[1].to_sym ],[@assos[-1].constantize, @assos[-2].to_sym]].uniq
		asso.each {|a| yield a[0], a[-1]}
	end

	private
	  def parse(asso={})
			keys = asso.keys
			values = asso.values.flatten
			"#{keys[0]}##{values[0]}##{values[-1]}##{keys[-1]}"
		end
end

class SymmetryTest < Test::Unit::TestCase

	def setup
	end

	def test_a_new_symmetry
		assert wh = Symmetry.new(User=>[:wife, :husband])
		assert f = Symmetry.new(User=>:friends)
		assert ui = Symmetry.new(User=>:icon, Icon=>:user)
		assert up = Symmetry.new(User=>:projects, Project=>:members)
		assert_equal wh.mirror(User), User
		assert_equal wh.mirror(:wife), :husband
		assert_equal wh.mirror(:husband), :wife
		assert_equal f.mirror(User), User
		assert_equal f.mirror(:friends), :friends
		assert_equal ui.mirror(User), Icon
		assert_equal ui.mirror(Icon), User
		assert_equal ui.mirror(:icon), :user
		assert_equal ui.mirror(:user), :icon
		assert_equal up.mirror(User), Project
		assert_equal up.mirror(Project), User
		assert_equal up.mirror(:projects), :members
		assert_equal up.mirror(:members), :projects
	end

	def test_symmetry_each
		assert wh = Symmetry.new(User=>[:wife, :husband])
		wh.each {|c, m|
			assert_equal c, User
			assert [:wife, :husband].include?(m)
	 	}
		assert f = Symmetry.new(User=>:friends)
		f.each {|c, m|
			assert_equal c, User
			assert_equal m, :friends
		}
		assert ui = Symmetry.new(User=>:icon, Icon=>:user)
		ui.each {|c, m|
		}
		assert up = Symmetry.new(User=>:projects, Project=>:members)
		up.each {|c, m|
		}
	end

end





require File.join(File.dirname(__FILE__),'..','helper')

class SinguPluralDic <  Test::Unit::TestCase

	def setup
	end

	def test_singu_plural
		assert "books".plural?
		assert !"books".singular?
		assert "book".singular?
		assert !"book".plural?
		Dic::SIN_WORDS.add("books") 
		assert "books".singular?
		assert !"books".plural?
		Dic::PLU_WORDS.add("books")
		assert !"books".singular?
		assert "books".plural?
		Dic::PLU_WORDS.add("book")
		assert !"book".singular?
		assert "book".plural?
		Dic::SIN_WORDS.add(["book", "dogs"])
		assert !"book".plural?
		assert "book".singular?
		assert "dogs".singular?
		assert !"dogs".plural?
	end

end

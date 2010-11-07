class String

	def plural?
		(Dic::PLU_WORDS.include?(self) || self.pluralize == self) && !Dic::SIN_WORDS.include?(self) 
	end

	def singular?
		(Dic::SIN_WORDS.include?(self) || self.singularize == self) && !Dic::PLU_WORDS.include?(self)
	end

end

module WordAct
	def add(words)
    if words.is_a? Array
			words.each {|w| self.add(w.to_s)}
		else
			self << words.to_s
			Dic::Mirror[self].delete(words.to_s)
			self.uniq!
		end
	end

	def hash
		self.object_id
	end
end

module Dic
	(SIN_WORDS = []).extend(WordAct)
	(PLU_WORDS = []).extend(WordAct)
	Mirror = {SIN_WORDS=>PLU_WORDS, PLU_WORDS=>SIN_WORDS}
end


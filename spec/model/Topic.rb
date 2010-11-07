class Topic < ActiveObject::Base
	attribute :title,:content,:create_time,:user_key,:posts

	before_create	do |object|
		object.create_time = Time.now
	end

	validates_presence_of :title,:content

	validate_on_create :title_is_wrong_create


  def validate_on_create
    if content == "Mismatch"
      errors.add("title", "is Content Mismatch")
    end
  end

  def title_is_wrong_create
    errors.add("title", "is Wrong Create") if  title == "Wrong Create"
  end

  def validate_on_update
    errors.add("title", "is Wrong Update") if  title == "Wrong Update"
  end
end

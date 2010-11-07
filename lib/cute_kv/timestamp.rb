module CuteKV
	# CuteKV automatically timestamps create and update operations if the table has fields
	# named created_at/created_on or updated_at/updated_on.
	#
	# Timestamping can be turned off by setting
	#   <tt>ActiveRecord::Base.record_timestamps = false</tt>
	#
	# Timestamps are in the local timezone by default but you can use UTC by setting
	#   <tt>CuteKV::Timestampes.default_timezone == :utc</tt>
	module Timestamp

		def self.included(base) #:nodoc:
			base.extend ClassMethods
			base.alias_method_chain :save, :timestamps
		end



		module ClassMethods
			def default_timezone
				@timezone = Timestamp::default_timezone
				@timezone.to_sym
			end

			def add_timestamps
				assign(:created_at, :updated_at) unless already_has_timestamp?
			end

			def already_has_timestamp?
				attrs = self.assigned_attributes
				attrs.include?(:created_at) && attrs.include?(:updated_at) 
			end

		end

		private

		def save_with_timestamps #:nodoc:
			t = self.class.default_timezone == :utc ? DateTime.now.utc : DateTime.now
			self.created_at ||= t if self.respond_to?(:created_at)
			self.updated_at = t if self.respond_to?(:updated_at)
			save_without_timestamps
		end


		class << self

			def default_timezone
				@default_tz ||= :utc
			end

		end

	end

end

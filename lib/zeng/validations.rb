module CuteKV

  module Validations

    def self.included(base)
      base.extend ClassMethods
      base.send :include, InstanceMethods
      base.class_eval { alias_method :validated, :save; alias_method :save, :validating }
    end

    class Error

      def initialize
        @body = Hash.new {|h,k| h[k] = []}
      end

      def add(attr, mesg)
        attr = attr.to_s
        @body[attr] << mesg unless @body[attr].include?(mesg)
      end

      def on(attr)
        attr = attr.to_s
        @body[attr].size == 1 ? @body[attr].first : @body[attr]
      end

      def empty?
        @body.values.flatten.empty?
      end

    end

    module InstanceMethods

      def validating
        self.class.validations.each {|v| self.send v}
        valid? ? validated : nil
      end

      def errors
        @errors ||= Error.new
      end

      def valid?
        self.errors.empty?
      end

      def errors_message_on(attr)
        self.errors.on(attr)
      end

    end

    module ClassMethods

      def validate(validate_process)
        (@validations ||=[]) << validate_process
      end

      def validations
        (@validations ||=[]).dup
      end

    end

  end

end

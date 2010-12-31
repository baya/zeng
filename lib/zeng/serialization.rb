module CuteKV#:nodoc:
  module Serialization
    class Serializer #:nodoc:
      attr_reader :options

      def initialize(object, options = {})
        @object, @options = object, options.dup
      end

      # To replicate the behavior in ActiveObject#attributes,
      # <tt>:except</tt> takes precedence over <tt>:only</tt>.  If <tt>:only</tt> is not set
      # for a N level model but is set for the N+1 level models,
      # then because <tt>:except</tt> is set to a default value, the second
      # level model can have both <tt>:except</tt> and <tt>:only</tt> set.  So if
      # <tt>:only</tt> is set, always delete <tt>:except</tt>.
      def serializable_attribute_names
        attribute_names = @object.assigned_attributes.collect {|n| n.to_s} << "id"

        if options[:only]
          options.delete(:except)
          attribute_names = attribute_names & Array(options[:only]).collect { |n| n.to_s }
        else
          options[:except] = Array(options[:except])
          attribute_names = attribute_names - options[:except].collect { |n| n.to_s }
        end

        attribute_names
      end

      def serializable_method_names
        Array(options[:methods]).inject([]) do |method_attributes, name|
          method_attributes << name if @object.respond_to?(name.to_s)
          method_attributes
        end
      end

      def serializable_names
        serializable_attribute_names + serializable_method_names
      end

      # Add associations specified via the <tt>:includes</tt> option.
      # Expects a block that takes as arguments:
      #   +association+ - name of the association
      #   +objects+     - the association object(s) to be serialized
      #   +opts+        - options for the association objects
      def add_includes(&block)
        if include_associations = options.delete(:include)
          base_only_or_except = { :except => options[:except],
                                  :only => options[:only] }

          include_has_options = include_associations.is_a?(Hash)
          associations = include_has_options ? include_associations.keys : Array(include_associations)

          for association in associations
            objects = @object.send association

            unless objects.nil?
              association_options = include_has_options ? include_associations[association] : base_only_or_except
              opts = options.merge(association_options)
              yield(association, objects, opts)
            end
          end

          options[:include] = include_associations
        end
      end

      def serializable_object
        returning(serializable_object = {}) do
          serializable_names.each { |name| serializable_object[name] = @object.send(name) }

          add_includes do |association, objects, opts|
            if objects.is_a?(Enumerable)
              serializable_object[association] = objects.collect { |r| self.class.new(r, opts).serializable_object }
            else
              serializable_object[association] = self.class.new(objects, opts).serializable_object
            end

          end
        end
      end

      def serialize
        # overwrite to implement
      end

      def to_s(&block)
        serialize(&block)
      end
    end
  end
end

require 'cute_kv/serializers/xml_serializer'
require 'cute_kv/serializers/json_serializer'

# -*- coding: utf-8 -*-
require 'yaml'
require 'uuid'
require 'json'
require 'json/add/core'

module CuteKV
  class CuteKVError < StandardError;end
  class ObjectNotSaved < CuteKVError; end

  #  CuteKV's built-in attribute id is the <t>key</t> to access <t>value</t>, and id is formated by uuid.
  #  ==
  #  CuteKV provide a Document module to persistence class's attributes, when a class include Document module,
  #  then it can <t>assign</t> attributes needed to persistence.
  #
  #    class User
  #      include CuteKV::Document
  #      assign :name,:age=>25,:gender=>"male"
  #    end
  #
  #    User have three persistence attributes: "name", "age"(default value is 25) and "gender"(default male)
  #    @jim = User.new(:name=>"jim")
  #    @jim.name               #=> "jim"
  #    @jim.age                #=> 25
  #    @jim.gender             #=> "male"
  #
  #  Every object has a default +id+, if you want to set primary key, you can use <t>primary_key</t> to set up.
  #
  #    class Account < ActiveObject::Base
  #      include CuteKV::Document
  #      assign :name,:email,:encrypt_password
  #      primary_key :email
  #    end
  #
  #  == New
  #     Use hash params to create a new object, example:
  #   user = User.new(:name => "David", :occupation => "Code Artist")
  #   user.name # => "David"
  #
  #     you can initialize object by using block
  #   user = User.new {|u| u.name = "David"; u.occupation = "Code Artist"}
  #
  #     Also，you can first create a bare object then assign values to it
  #   user = User.new
  #   user.name = "David"
  #   user.occupation = "Code Artist"
  #
  #  == Create
  #
  #  == Update
  #
  #  == Destroy
  #
  #     ==== params
  #
  # * +object+ is what you want to destroy
  #
  #     ==== example
  #     jim = User.create(:name=>"jim")
  #   User.Destroy(jim)
  #   if Account.destroy(jim) will return nil, because jim is not a instance object of Account.


  module Document

    def self.included(base)
      base.extend ClassMethods
      # select serializers, exmaple "json", ",marshal", default is "json"
      base.select_serializer(:json)
      base.send :include, InstanceMethods
      base.send :include, Serialization
      base.send :include, Timestamp
      add_client(base) unless clients.include?(base)
    end

    module InstanceMethods
      attr_reader :id

      def initialize(attributes={}, new_id=true)
        if new_id
          @id = UUID.new.generate
          assigned_attrs = self.class.read_assigned_attributes_with_default_values
          attributes.each_key {|key| assigned_attrs.delete(key)}
          attributes.merge!(assigned_attrs)
        end
        attributes.each {|attr, value| self.send "#{attr}=", value if self.respond_to? "#{attr}=" }
        yield self if block_given?
      end

      # we protect class's backend from instance objects
      def save
        self.class.save(self)
      end

      def serialized_attributes
        seri_attrs = assigned_attributes.inject({}){|h,attr|
          h[attr] = self.send attr if self.respond_to? attr
          h
        }
        #
        #don't use :id, or you will get @id=nil when you use marshal to serialize object's attributes
        seri_attrs["id"] = @id
        self.class.serialize seri_attrs
      end

      def assigned_attributes
        self.class.assigned_attributes
      end

      # update object's attributes
      # <tt>attributes</tt>are the attributes needed to be updated
      def update(attributes={})
        self.class.update(self, attributes)
      end



      # reload object from database
      def reload
        self.class.reload(self)
      end

      # destroy self from database
      def destroy
        self.class.destroy(self)
      end

      def assigned_attributes_values
        self.assigned_attributes.inject({}){|h,attr| h[attr] = self.send attr; h  }
      end

    end

    module ClassMethods

      # Assigning attributs needed to persistence
      #  Example:
      #    class User
      #      include CuteKV::Document
      #      assign :name, :country=>"China", :gender=>"male"
      #    end
      def assign(*attributes)
        attrs = attributes.inject({}){ |h,attr|
          if attr.is_a? Hash
            attr.each {|k, v| attr_accessor k; h[k.to_sym] = v }
          else
            attr_accessor attr
            h[attr.to_sym] = nil
          end
          h
        }
        write_assigned_attributes_with_default_values(attrs)
      end

      def write_assigned_attributes_with_default_values(attributes={})
        (@assigned_attributes_with_default_values ||={}).merge!(attributes)
      end

      def read_assigned_attributes_with_default_values
        @assigned_attributes_with_default_values.dup
      end

      def assigned_attributes
        @assigned_attributes_with_default_values.keys
      end

      def backend
        @backend
      end


      #empty database
      def clear
        @backend.clear
      end


      # Configure CuteKV's Back-end database,now support LightCloud/TokyoTyrant/TokyoCabinet.
      #   +adapter+ specify what database to use
      #     :TC => TokyoCabinet (few to use :TC in our practice projects)
      #     :TT => TokyoTyrant
      #     :LC => LightCloud
      #
      #  +config+ is the config infos about back-end
      #           when +adapter+ is specified to :TT, +config+ coulde be a String or Hash
      #     String:
      #       User.backend_configure :TT, "127.0.0.1:1985"
      #     or Hash:
      #       User.backend_configure :TT, :host=>'127.0.0.1', :port=>1985
      #
      #
      #Back-end database,now we support tokyotyrant, lightcloud
      def backend_configure(adapter, config)
        @backend = Connector.new(adapter,config)
      end


      # 返回当前对象的数据库和索引配置信息
      def backend_configurations
        @backend.infos
      end


      #
      # find object by it's +id+
      # ==== Example
      #   User.find('aaron@nonobo.com') return an User's instance object
      #   if User's backend has this id or return nil
      def find(id)
        return if id.nil?
        raw_value = @backend.get(id)
        return if raw_value.nil?
        value = deserialize raw_value
        active(value)
      end

      # Active sleeped value so we'll get a live object :-)
      # It's should not generate a new id, because this value has included a id
      def active(value, new_id=false)
        id = value.delete("id")
        new(value, new_id) {|obj| obj.instance_variable_set(:@id, id)}
      end

      def all
      end

      # Create one or more objects and save them to database
      # return objects you have created
      # parameters +attributes+ is Hash or hash Array
      #
      # ==== Example
      #   # create single object
      #   User.create(:first_name => 'Jamie')
      #
      #   # create more objects
      #   User.create([{ :first_name => 'Jamie' }, { :first_name => 'Jeremy' }])
      #
      #   # create an object, and assign values to attributes through block
      #   User.create(:first_name => 'Jamie') do |u|
      #     u.is_admin = false
      #   end
      #
      def create(attributes = {}, &block)
        object = new(attributes)
        yield(object) if block_given?
        object.save
        object
      end

      def save(object)
        object.is_a?(self) ? @backend.put(object.id, object.serialized_attributes) : nil
      end

      def update(object, attributes={})
        object.is_a?(self) ? attributes.each{|key,value|
          object.send("#{key}=",value) if object.respond_to? "#{key}="
        } : nil
      end

      def reload(object)
        return unless object.is_a?(self)
        raw_value = @backend.get(object.id)
        return if raw_value.nil?
        value = deserialize raw_value
        update(object, value)
      end


      # destroy object who is an instance of Actors # and execute all callback and filt actions
      # ==== Example
      #   aaron = User.create(:name=>"aaron")
      #   User.destroy(aaron)
      def destroy(object)
        object.is_a?(self) ? @backend.delete(object.id) : nil
      end

      Serializers ={
        :json => {:ser=> lambda{|value| JSON.generate(value)},
          :desr=>lambda{|raw| JSON.parse(raw)},
          :type=>"json"
        },
        :marshal => {:ser=> lambda{|value| Marshal.dump(value)},
          :desr=>lambda{|raw| Marshal.load(raw)},
          :type => "marshal"
        }
      }

      def select_serializer(type=:json)
        @serializer = Serializers[type]
      end

      def serializer_type
        @serializer[:type]
      end

      def serialize(value)
        @serializer[:ser].call(value)
      end

      def deserialize(raw_value)
        @serializer[:desr].call(raw_value)
      end

    end

    class << self
      def backend_configure(klass,adapter, host_port )
      end

      # docking external mod, so that expanding Document's functions
      # and class who has included Document will hold the exteranl mod's methods.
      def docking(mod)
        @clients.each {|client| client.send :include, mod }
      end

      def add_client(client)
        (@clients ||= []) << client if client.is_a? Class
      end

      def clients
        (@clients ||= []).dup
      end

    end

  end

end

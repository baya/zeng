module CuteKV
  module Indexer
    Map = Class.new
    Collection = Class.new(Array)

    def self.included(base)
      base.extend ClassMethods
      base.send :include, InstanceMethods
    end

    module InstanceMethods
      attr_reader :key, :values
      attr_accessor :index_attrs


      def initialize(key, value)
        @key = key
        @values = JSON.parse value
      end

      def save
        self.class.save(self)
      end

      def objects
        map = self
        index_attrs = self.index_attrs
        Collection.class_eval {
          define_method(:<<){|obj|
            old = map.values.assoc(obj.id)
            map.values.delete(old)
            index = index_attrs.inject({}){
              |h, attr| h[attr] = obj.send(attr) if obj.respond_to?(attr)
              h
            }
            index.merge!(:id=>obj.id)
            map.values << [obj.id,index]
            map.save

          }
        }
        values = Collection.new.replace(self.values)
      end

    end

    module ClassMethods
      def connect(klass)
        @backend = klass.backend
      end

      def find(key)
        new(key, @backend[key]) if @backend[key]
      end

      def create(key, values=[])
        value = JSON.generate values
        @backend[key] = value
        new(key, value)
      end

      def save(map)
        @backend[map.key] = JSON.generate map.values
      end

      def find_or_create(key)
        find(key) || create(key)
      end

    end


    class << self

      def map(class_attrs={})
        c = class_attrs.keys[0]
        attrs = class_attrs.values.flatten
        key = "#{c}-index-#{attrs.join('-')}"
        index_map = Map.send(:include, self)
        index_map.connect(c)
        klass = class << c; self; end
        klass.instance_eval {
          define_method(:indexes){
            map = index_map.find_or_create(key)
            map.index_attrs = attrs
            map.objects
          }
          attrs.each {|attr|
            define_method("find_all_by_#{attr}"){|value|
              c.indexes.map {|index|
                c.find(index[-1]['id']) if index[-1][attr.to_s] == value
              }.compact
            }
          }
        }
        true
      end

    end

  end
end

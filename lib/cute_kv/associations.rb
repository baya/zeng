module CuteKV
  module Associations

    Map = Class.new
    Collection = Class.new(Array) {
      def to_json(options={})
        "[#{self.map{|c| c.to_json(options)}.join(',')}]"
      end
    }

    class Symmetry

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

    def self.included(base)
      base.send :include, InstanceMethods
      base.extend ClassMethods
    end

    module InstanceMethods

      def initialize(key, ids)
        @key_infos = key.split('#')
        @klass = @key_infos[-1].constantize
        @key = key
        @ids = deserialize ids
      end

      def ids
        @ids
      end

      def relex(object)
        r_k = @key_infos[0]
        r_v = @key_infos[1]
        k = @key_infos[-1]
        v = @key_infos[-2]
        key = "#{k}##{v}##{object.id}#relations##{r_v}##{r_k}"
        map = self.class.find(key) || self.class.create(key, [])
      end


      def objects
        map = self
        #it is very strange! when i use 'id', i can't use the method 'remove' correctly, so i use '_id'
        _id = @key_infos[2]
        _klass = @klass
        _rv = @key_infos[1]
        objs = Collection.new
        objs.replace self.ids.collect {|id| @klass.find(id)}.compact
        self.ids = objs.map(&:id) unless objs.size == self.ids.size
        Collection.class_eval {
          define_method(:<<){|object|
            return unless object.is_a? _klass
            if _rv.singular?
              map.send(:ids=, [object.id])
            else
              map.ids << object.id
            end
            rel_map = map.relex(object)
            rel_map.ids << _id
            map.save
            rel_map.save
          }

          define_method(:remove) {|object|
            return unless object.is_a? _klass
            map.ids.delete(object.id)
            rel_map = map.relex(object)
            rel_map.ids.delete(_id)
            map.save
            rel_map.save
          }


        }
        objs
      end

      def save
        self.class.backend[@key] = serialize @ids
      end


      private
      def ids=(ids)
        return unless ids.is_a? Array
        @ids = ids
      end

      def serialize(ids)
        self.class.send :serialize, ids
      end

      def deserialize(raw_ids)
        self.class.send :deserialize, raw_ids
      end

    end


    module ClassMethods

      def connect(class_obj)
        @backend = class_obj.backend
        @class_obj = class_obj
      end

      def find(key)
        new(key, @backend[key]) if @backend[key]
      end

      def create(key,ids=[])
        ids = serialize ids
        @backend[key] = ids
        new(key, ids)
      end

      def backend
        @backend
      end

      def find_or_create(key)
        find(key) || create(key, [])
      end

      def gen_key(k, v, object, r_v, r_k)
        key = "#{k}##{v}##{object.id}#relations##{r_v}##{r_k}"
      end

      def draw(k, v, object, r_v, r_k)
        key = gen_key(k, v, object, r_v, r_k)
        find_or_create(key)
      end

      private

      def serialize(ids)
        @class_obj.serialize(ids)
      end

      def deserialize(raw_ids)
        @class_obj.deserialize(raw_ids)
      end

    end

    class << self
      # Although relations between real word's objects are complex, we abstract all relations to three
      # type relations: # <tt>one_to_one</tt>, # <tt>one_to_many</tt>, # <tt>many_to_many</tt>
      #
      # == One_To_One
      #   class User < ActiveObject::Base
      #     assign :name, :gender=>"male"
      #   end
      #
      #   class Icon < ActiveObject::Base
      #     assign :path
      #   end
      #   @aaron = User.create(:name=>"aaron")
      #   @icon = Icon.create(:path=>"/tmp/aaron.jpg")
      #
      #   Associations::map(User=>:icon, Icon=>:user)
      #   User will add a instance method :icon
      #   Icon will add a instance method :user
      #   @aaron.icon = @icon
      #   aaron = User.find(@aaron.id)
      #   aaron.icon.path                      #=>"/tmp/aaron.jpg"
      #   icon = Icon.find(@icon.id)
      #   icon.user.name                       #=>"aaron"
      #
      #   Associations::map(User=>[:wife, :husband])
      #   @rita = User.create(:name=>"rita", :gender=>'female')
      #   @aaron.wife = @rita
      #   @aaron.wife                         #=>@rita
      #   @rita.husband                       #=>@aaron
      #
      # == One_To_Many
      #   Associations::map(User=>:books, Book=>:owner)
      #   @book_ruby = Book.create(:name=>"Ruby")
      #   @book_java = Book.create(:name=>"Java")
      #
      # == Many_To_Many
      #   Associations::map(User=>:projects, Project=>:members)
      #   @aaron = User.create(:name=>"aaron")
      #   @nonobo = Project.create(:name=>"nonobo")
      #   @admin = Project.create(:name=>"admin")
      #   @aaron.prjects << @nonobo
      #   @aaron.prjects << @admin
      #   @aaron.projects   #=>[@nonobo, @admin]
      #   @nonobo.members   #=>[@aaron]
      #   @aaron.projects.remove(@nonbo)
      #   @nonbo.members   #=> []
      #   @aaron.projects   #=> [@admin]
      #
      #
      def map(asso)
        if asso.is_a? String
          #load classes's associations from yml file
          assos = YAML::load(IO.read(asso))
          assos.each {|asso| map(constantize_asso_keys(asso)) }
        else
          singus = Array(asso.delete(:singular)).compact
          Dic::SIN_WORDS.add(singus) unless singus.empty?
          pluras = Array(asso.delete(:plural)).compact
          Dic::PLU_WORDS.add(pluras) unless pluras.empty?
          symmetry = Symmetry.new(asso)
          symmetry.each {|k,v|
            r_k = symmetry.mirror(k)
            r_v = symmetry.mirror(v)
            asso_map = Map.send(:include, self)
            asso_map.connect(k)
            k.class_eval {
              define_method(v) {
                map = asso_map.draw(k,v,self,r_v,r_k)
                if v.singular?
                  obj = map.objects.last
                  return if obj.nil?
                  def obj.remove(object)
                    Collection.new.replace([self]).remove(object)
                  end
                  obj
                else
                  map.objects
                end
              }

              define_method("#{v}=") {|object|
                return if object.nil?
                map = asso_map.draw(k,v,self,r_v,r_k)
                vo = self.send(v)
                vo.send(r_v).remove(self) if vo
                rvo = object.send(r_v)
                rvo.send(v).remove(object) if r_v.singular? && rvo
                map.objects << object
              } if v.singular?

            }
          }
        end

      end

      protected

      def constantize_asso_keys(asso)
        h = {}
        plurs = asso.delete("plural").split(" ") if asso["plural"]
        sins = asso.delete("singular").split(" ") if asso["singular"]
        h[:plural] = plurs if plurs
        h[:singular] = sins if sins
        asso.each {|k,v| h[k.constantize] = v.split(' ') }
        h
      end

    end

  end


end

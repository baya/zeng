Zeng -- based at Ruby for object-key/value map
==============================================


Main features
-------------

- **Independent Object Storage**

  Through backend_configure to appoint storage location

        class User
           include Zeng::Document
           backend_configure :TT,"127.0.0.1:1987"
        end

- **Customize define persistent properties**

  You can assign persitent properties by **assign** method,and set default value for each property.

        class User
           include Zeng::Document
           backend_configure :TT,"127.0.0.1:1987"
           assign :name, :email, :gender=>'male', :age=>25
        end


Index
-----

        class User
          include Zeng::Document
          backend_configure :TT,"127.0.0.1:1987"
          assign :name,:email, :gender=>'male', :age=>25
        end

        @jim = User.create(:name=>"jim", :email=>"jim@nonobo.com")
        @aaron = User.create(:name=>"aaron", :email=>"aaron@nonobo.com")
        @jack= User.create(:name=>"jack", :email=>"jack@nonbo.com")
        @lucy = User.create(:name=>"lucy", :email=>"lucy@nonobo.com")

Using **Zeng::Indexer** module, you can build index for object, just like:

        Zeng::Indexer::map(User=>[:name, :email, :age])

then,


        User.indexes << @jim
        User.indexes << @aaron
        User.indexes << @lucy
        User.find_all_by_name("jim")     #=>@jim
        User.find_all_by_age(25)         #=>@jim, @aaron, @lucy, @jack

Supoort multiple database
------------------------
Zeng using adapter to connect database backend, now support **TokyoCabinet**/**TokyoTyrant**。


Using in rails
--------------
  in environment.rb, you will add

       require 'zeng

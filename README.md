Zeng -- a data mapper tool for nosql database
==============================================

Main features
-------------

- **Install**

  sudo gem install zeng

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

Benchmark
---------
You will find benchmark file in bc/book_bc.rb and bc/ac_book_bc.rb

Platform is Ubuntu10.04, ruby1.8.7, cpu:AMD Athlon(tm) Neo X2 1.6GHz memory:1.7G

  activerecord mysql write 100,00,00 records
  1617.170000 189.330000 1806.500000 (1970.941057)

  zeng tokyocabinet write 100,00,00 records
  607.300000 496.330000 1103.630000 (1907.321967)



Using in rails
--------------
  in environment.rb, you will add

       require 'zeng'

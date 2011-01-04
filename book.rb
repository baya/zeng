require 'rubygems'
require 'zeng'

class Book
  include Zeng::Document
  backend_configure(:TT, '127.0.0.1:1988')
  assign :name, :price
end

Zeng::Indexer::map(Book => [:name])

book = Book.create(:name => "ruby book", :price => 12.0)
Book.indexes << book

book = Book.find(book.id)
puts book.inspect
puts book.name
puts book.price.class
puts book.price

books = Book.find_all_by_name("ruby book")
puts books.inspect


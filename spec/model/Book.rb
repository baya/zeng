class Book
  include Zeng::Document
  backend_configure(:TT, '127.0.0.1:1988')
  assign(:name)
end


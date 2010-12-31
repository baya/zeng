class User
  include Zeng::Document
  assign :name, :email
  backend_configure(:TT, '127.0.0.1:1985')
end

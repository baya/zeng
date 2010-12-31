class Project
  include Zeng::Document
  assign :name
  backend_configure(:TT, '127.0.0.1:1987')
end

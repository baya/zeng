class Icon
  include Zeng::Document
  assign :name, :path
  backend_configure(:TT, '127.0.0.1:1986')
end

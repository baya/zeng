class Project 
	include CuteKV::Document
  assign :name
  backend_configure(:TT, '127.0.0.1:1987')
end

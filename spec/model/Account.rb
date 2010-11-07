class Account 
	include CuteKV::Document
	assign :name, :email
  backend_configure(:TT, '127.0.0.1:1986')
end

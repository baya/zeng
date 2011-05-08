# start ttserver at port 1987
# $ttserver -dmn -port 1987 -pid /tmp/ttserver.pid /tmp/zeng_book.tch
require 'rubygems'
require 'benchmark'
require 'zeng'

def start_tt_server(port = 1987)
  system "ttserver -dmn -port #{port} -pid /tmp/ttserver.pid /tmp/zeng_book.tch"
end

def stop_tt_server
  system "kill -TERM `cat /tmp/ttserver.pid` "
  system "rm /tmp/zeng_book.tch"
end

start_tt_server

N = 10**6
class ZengBook
  include Zeng::Document
  backend_configure :TT, "127.0.0.1:1987"
  assign :name
end

bc1 = Benchmark.measure do
  for i in 1..N
    ZengBook.create(:name => "jim#{i}")
  end
end

stop_tt_server

puts bc1

# ubuntu10.04, ruby1.8.7, cpu:AMD Athlon(tm) Neo X2 1.6GHz memory:1.7G
# 607.300000 496.330000 1103.630000 (1907.321967)

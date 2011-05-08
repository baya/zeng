require 'rubygems'
require 'activerecord'

N = 10**6
class AcBook < ActiveRecord::Base
  establish_connection(
                       :adapter  => "mysql",
                       :host     => "localhost",
                       :username => "root",
                       :password => "123456",
                       :database => "ac_bench"
                       )
end

bc = Benchmark.measure do
  for i in 1..N
    AcBook.create(:name => "jim#{i}")
  end
end

puts bc

# ubuntu10.04, ruby1.8.7, cpu:AMD Athlon(tm) Neo X2 1.6GHz memory:1.7G
# 1617.170000 189.330000 1806.500000 (1970.941057)

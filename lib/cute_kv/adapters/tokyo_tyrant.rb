# 访问TokyoTyrant的加载模块
require 'rufus/tokyo'
require 'cute_kv/adapters/tokyo_cabinet'
module CuteKV
	module Adapters
		module TokyoTyrant
			include CuteKV::Adapters::TokyoCabinet
			private
				def establish(conf)
					if conf.is_a? Hash
						@host = conf[:host] || conf["host"]
						@port = (conf[:port] || conf["port"]).to_i
					else
						conf = conf.split(':')
						@host = conf[0]
						@port = conf[1].to_i
					end
					@db = Rufus::Tokyo::Tyrant.new(@host, @port)
				end
		end
	end
end

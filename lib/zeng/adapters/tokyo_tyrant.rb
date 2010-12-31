# -*- coding: utf-8 -*-
# 访问TokyoTyrant的加载模块
require 'tokyotyrant'
require 'zeng/adapters/tokyo_cabinet'
include TokyoTyrant

module Zeng
  module Adapter
    module TokyoTyrant
      include Adapter::TokyoCabinet

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
        @db = ::RDB.new
        if !@db.open(@host, @port)
          ecode = @db.ecode
          raise @db.errmsg(ecode)
        end
      end
    end
  end
end

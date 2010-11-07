# -*- coding: utf-8 -*-
# 访问TokyoCabinet的加载模块
require 'rufus/tokyo'
module CuteKV
  module Adapters
    module TokyoCabinet
      def put(key, value)
        @db[key] = value
      end

      def get(key)
        @db[key]
      end

      def delete(key)
        @db.delete(key)
      end

      def infos
        {:adapter=>@adapter, :host=>@host, :port=>@port}
      end

      def method_missing(method, *args)
        @db.send method, *args
      end

      private
      def establish(conf)
        @db = Rufus::Tokyo::Cabinet.new(conf)
      end
    end
  end
end

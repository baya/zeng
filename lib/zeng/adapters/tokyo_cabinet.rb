# -*- coding: utf-8 -*-
# 访问TokyoCabinet的加载模块
require 'tokyocabinet'
module Zeng
  module Adapter
    module TokyoCabinet

      def put(key, value)
        @db.put(key, value)
      end

      def get(key)
        @db.get(key)
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
        @db = HDB::new(conf)
      end
    end
  end
end

# -*- coding: utf-8 -*-
# 访问LightCloud的加载模块
require 'lightcloud'
module CuteKV
  module Adapters
    module TokyoCloud
      def put(key, value)
        @db.set(key, value)
      end

      def get(key)
        @db.get(key)
      end

      private
      def establish(conf)
        conf = YAML.load_file(conf) if conf.is_a?(String)
        lookup_nodes, storage_nodes = LightCloud.generate_nodes(conf)
        @db = LightCloud.new(lookup_nodes, storage_nodes)
      end
    end
  end
end

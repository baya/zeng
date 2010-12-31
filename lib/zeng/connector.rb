# -*- coding: utf-8 -*-
module Zeng
  class Connector
    def self.config(adapter)
      case adapter.to_sym
      when :TC
        require 'zeng/adapters/tokyo_cabinet'
        include Adapter::TokyoCabinet
      when :TT
        require 'zeng/adapters/tokyo_tyrant'
        include Adapter::TokyoTyrant
      when :LC
        require 'zeng/adapters/light_cloud'
        include Adapter::TokyoCloud
      else
        raise ConfigError,'没有指定数据库类型！'
      end
    end

    def initialize(adapter, conf)
      @adapter = adapter
      self.class.config(adapter)
      establish(conf)
    end

  end

end

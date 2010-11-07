module CuteKV
  class Connector
    def self.config(adapter)
      case adapter.to_sym
			  when :TC 
						require 'cute_kv/adapters/tokyo_cabinet'
						include CuteKV::Adapters::TokyoCabinet
			  when :TT 
						require 'cute_kv/adapters/tokyo_tyrant'
						include CuteKV::Adapters::TokyoTyrant
			  when :LC 
						require 'cute_kv/adapters/light_cloud'
						include CuteKV::Adapters::TokyoCloud
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

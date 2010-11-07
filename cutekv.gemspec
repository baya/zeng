# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{cutekv}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Guimin Jiang"]
  s.date = %q{2010-01-19}
  s.description = %q{CuteKV -- based at Ruby for object-key/value map}
  s.email = ["kayak.jiang@gmail.com"]
  s.files = ["./README", "./MIT-LICENSE", "./CHANGE", "./examples", "./examples/user.rb", "./examples/light_cloud.yml", "./examples/account.rb", "./spec", "./spec/helper.rb", "./spec/case", "./spec/case/timestamp_test.rb", "./spec/case/indexer_test.rb", "./spec/case/db_index_test.rb", "./spec/case/cache_test.rb", "./spec/case/document_test.rb", "./spec/case/callbacks_test.rb", "./spec/case/callbacks_observers_test.rb", "./spec/case/serialization_test.rb", "./spec/case/map_test.rb", "./spec/case/sin_plu_dic_test.rb", "./spec/case/db_config_test.rb", "./spec/case/validations_test.rb", "./spec/case/association_test.rb", "./spec/case/symmetry_test.rb", "./spec/asso_sin_plural.yml", "./spec/asso.yml", "./spec/model", "./spec/model/Book.rb", "./spec/model/Icon.rb", "./spec/model/User.rb", "./spec/model/Friend.rb", "./spec/model/Topic.rb", "./spec/model/Account.rb", "./spec/model/Project.rb", "./spec/light_cloud.yml", "./tags", "./lib", "./lib/cute_kv", "./lib/cute_kv/serializers", "./lib/cute_kv/serializers/json_serializer.rb", "./lib/cute_kv/serializers/xml_serializer.rb", "./lib/cute_kv/callbacks.rb", "./lib/cute_kv/document.rb", "./lib/cute_kv/validations.rb", "./lib/cute_kv/ext", "./lib/cute_kv/ext/string.rb", "./lib/cute_kv/ext/symbol.rb", "./lib/cute_kv/serialization.rb", "./lib/cute_kv/indexer.rb", "./lib/cute_kv/observer.rb", "./lib/cute_kv/associations.rb", "./lib/cute_kv/connector.rb", "./lib/cute_kv/adapters", "./lib/cute_kv/adapters/tokyo_tyrant.rb", "./lib/cute_kv/adapters/tokyo_cabinet.rb", "./lib/cute_kv/adapters/light_cloud.rb", "./lib/cute_kv.rb", "./Rakefile.rb", "./init.rb"]
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.6")
  s.rubygems_version = %q{1.3.5}
  s.summary = nil

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<ffi>, [">= 0"])
    else
      s.add_dependency(%q<ffi>, [">= 0"])
    end
  else
    s.add_dependency(%q<ffi>, [">= 0"])
  end
end

$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'
require 'lightcloud'
require 'active_support'
require 'cute_kv/ext/string'
require 'cute_kv/ext/symbol'
require 'cute_kv/document'
require 'cute_kv/validations'
require 'cute_kv/connector'
require 'cute_kv/associations'
require 'cute_kv/indexer'
require 'cute_kv/serialization'
require 'cute_kv/connector'
require 'cute_kv/timestamp'


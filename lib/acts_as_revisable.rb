$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

begin
  require 'activesupport' unless defined? ActiveSupport
  require 'activerecord' unless defined? ActiveRecord
rescue LoadError
  require 'rubygems'
  require 'active_support' unless defined? ActiveSupport
  require 'active_record/railtie' unless defined? ActiveRecord
end

require 'acts_as_revisable/version.rb'
require 'acts_as_revisable/base'

ActiveRecord::Base.send(:include, WithoutScope::ActsAsRevisable)

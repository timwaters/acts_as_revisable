begin
  require 'rspec'
rescue LoadError
  require 'rubygems'
  gem 'rspec'
  require 'rspec'
end

if ENV['EDGE_RAILS_PATH']
  edge_path = File.expand_path(ENV['EDGE_RAILS_PATH'])
  require File.join(edge_path, 'activesupport', 'lib', 'active_support')
  require File.join(edge_path, 'activerecord', 'lib', 'active_record')
end

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'acts_as_revisable'

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

def setup_db
  ActiveRecord::Schema.define(:version => 1) do
    create_table :people do |t|
      t.string :name, :revisable_name, :revisable_type
      t.text :notes
      t.boolean :revisable_is_current
      t.integer :revisable_original_id, :revisable_branched_from_id, :revisable_number, :project_id
      t.datetime :revisable_current_at, :revisable_revised_at, :revisable_deleted_at
      t.timestamps
    end
    
    create_table :projects do |t|
      t.string :name, :unimportant, :revisable_name, :revisable_type
      t.text :notes
      t.boolean :revisable_is_current
      t.integer :revisable_original_id, :revisable_branched_from_id, :revisable_number
      t.datetime :revisable_current_at, :revisable_revised_at, :revisable_deleted_at
      t.timestamps
    end
    
    create_table :foos do |t|
      t.string :name, :revisable_name, :revisable_type
      t.text :notes
      t.boolean :revisable_is_current
      t.integer :revisable_original_id, :revisable_branched_from_id, :revisable_number, :project_id
      t.datetime :revisable_current_at, :revisable_revised_at, :revisable_deleted_at
      t.timestamps
    end
    
    create_table :posts do |t|
      t.string :name, :author, :title, :tag, :revisable_name, :revisable_type, :type
      t.boolean :revisable_is_current
      t.integer :revisable_original_id, :revisable_branched_from_id, :revisable_number
      t.datetime :revisable_current_at, :revisable_revised_at, :revisable_deleted_at
      t.timestamps
    end

    create_table :domestic_cats do |t|
      t.string :name, :revisable_name, :revisable_type, :type
      t.text :description
      t.boolean :revisable_is_current
      t.integer :revisable_original_id, :revisable_branched_from_id, :revisable_number
      t.datetime :revisable_current_at, :revisable_revised_at, :revisable_deleted_at
      t.timestamps
    end

    create_table :plans do |t|
      t.string :name, :revisable_name, :revisable_type, :type
      t.boolean :revisable_is_current
      t.integer :revisable_original_id, :revisable_branched_from_id, :revisable_number, :price
      t.datetime :revisable_current_at, :revisable_revised_at, :revisable_deleted_at
      t.timestamps
    end

    create_table :subscriptions do |t|
      t.string :name, :revisable_name, :revisable_type, :type
      t.boolean :revisable_is_current
      t.integer :revisable_original_id, :revisable_branched_from_id, :revisable_number, :plan_id, :plan_vid
      t.datetime :revisable_current_at, :revisable_revised_at, :revisable_deleted_at
      t.timestamps
    end
    
  end
end

setup_db

def cleanup_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.execute("delete from #{table}")
  end
end

class Person < ActiveRecord::Base
  belongs_to :project
  
  acts_as_revisable do
    revision_class_name "OldPerson"
    on_delete :revise
  end
end

class OldPerson < ActiveRecord::Base
  acts_as_revision do
    revisable_class_name "Person"
    clone_associations :all
  end
end

class Project < ActiveRecord::Base
  has_many :people
  
  acts_as_revisable do
    revision_class_name "Session"
    except :unimportant
  end
end

class Session < ActiveRecord::Base
  acts_as_revision do
    revisable_class_name "Project"
    clone_associations :all
  end
end

class Foo < ActiveRecord::Base
  acts_as_revisable :generate_revision_class => true, :no_validation_scoping => true
  
  validates_uniqueness_of :name
end

class Post < ActiveRecord::Base
  acts_as_revisable 
  
  validates_uniqueness_of :name
  validates :title, :uniqueness => true
  validates :author, :uniqueness => {:scope => :tag}
end

class PostRevision < ActiveRecord::Base
  acts_as_revision
end

class Article < Post
  acts_as_revisable
end

class ArticleRevision < PostRevision
  acts_as_revision
end

## Association specific specs ##
class Plan < ActiveRecord::Base
  has_many :type_one_subscriptions
  has_many :type_two_subscriptions
  has_many :default_subscriptions

  acts_as_revisable do
    revision_class_name "PlanRevision"
    only :price
    has_many_fixations :type_one_subscriptions, :type_two_subscriptions
  end
end

class PlanRevision < ActiveRecord::Base
  acts_as_revision do
    revisable_class_name "Plan"
  end
end

class TypeOneSubscription < ActiveRecord::Base
  self.table_name = :subscriptions
  belongs_to :plan

  acts_as_revisable do
    revision_class_name "TypeOneSubscriptionRevision"
    belongs_to_fixations :plan => :original
  end
end

class TypeOneSubscriptionRevision < ActiveRecord::Base
  acts_as_revision do
    revisable_class_name "TypeOneSubscription"
  end
end

class TypeTwoSubscription < ActiveRecord::Base
  self.table_name = :subscriptions
  belongs_to :plan

  acts_as_revisable do
    revision_class_name "TypeTwoSubscriptionRevision"
    belongs_to_fixations :plan => :first
  end
end

class TypeTwoSubscriptionRevision < ActiveRecord::Base
  acts_as_revision do
    revisable_class_name "TypeTwoSubscription"
  end
end

class DefaultSubscription < ActiveRecord::Base
  self.table_name = :subscriptions
  belongs_to :plan

  acts_as_revisable do
    revision_class_name "DefaultSubscriptionRevision"
  end
end

class DefaultSubscriptionRevision < ActiveRecord::Base
  acts_as_revision do
    revisable_class_name "DefaultSubscription"
  end
end

module Domestic
  def self.table_name_prefix
    "domestic_"
  end
  class Cat < ActiveRecord::Base
    validates_presence_of :name
    acts_as_revisable do
      revision_class_name "Domestic::CatRevision"
    end
  end
  class CatRevision < ActiveRecord::Base
    acts_as_revision do
      revisable_class_name "Domestic::Cat"
    end
  end
end

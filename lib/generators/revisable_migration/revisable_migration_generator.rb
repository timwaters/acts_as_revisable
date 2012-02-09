class RevisableMigrationGenerator < Rails::Generators::NamedBase
  include Rails::Generators::Migration
  
  source_root File.expand_path('../templates', __FILE__)
  argument :name, :type => :string
  
  def self.next_migration_number(migration_dir)
    Time.now.strftime('%Y%m%d%s')[0,14]
  end
  
  def manifest
    raise "Supply the class you'd like to make revisable." if name.blank?
    @revisable_columns = [
      ["revisable_original_id",      "integer"],
      ["revisable_branched_from_id", "integer"],
      ["revisable_number",           "integer", 0],
      ["revisable_name",             "string"],
      ["revisable_type",             "string"],
      ["revisable_current_at",       "datetime"],
      ["revisable_revised_at",       "datetime"],
      ["revisable_deleted_at",       "datetime"],
      ["revisable_is_current",       "boolean", 1]
    ]
    @target_class = target_class
    migration_template 'migration.rb', "db/migrate/make_#{target_class.table_name}_revisable"
  end
  private
    def target_class
      name.constantize
    end
end

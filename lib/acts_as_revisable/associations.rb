module WithoutScope
  module ActsAsRevisable
    # This module is mixed into the revision and revisable classes to add associations
    # by correct version.
    module Associations
      def self.included(base) #:nodoc:
        # Override assocation helpers 
        base.revisable_class.reflect_on_all_associations(:belongs_to).each do |r|
          base.class_eval <<-"end_eval", __FILE__, __LINE__
            def #{r.name}(*args)
              if #{(base.revisable_class.revisable_options.belongs_to_fixations || {}).include?(r.name)} && self.respond_to?(:#{r.name}_vid) && !self.#{r.name}_vid.nil?
                #{r.class_name}.unscoped.where("revisable_number = :rev_num AND (id = :id OR revisable_original_id = :id)", :rev_num => self.#{r.name}_vid, :id => self.#{r.options[:foreign_key] || "#{r.name}_id"}).first
              else
                if current_revision?
                  super(*args) 
                else
                  current_revision.send(:#{r.name}, *args)
                end
              end
            end
          end_eval
        end

        base.revisable_class.reflect_on_all_associations(:has_many).each do |r|
          unless [:revisions, :branches, base.revision_class_name.tableize.to_sym].include?(r.name)
            [:' ', :_ids].each do |helper|
              method_name = ((helper == :_ids || helper == :_ids=) && r.name.to_s.singularize || r.name.to_s) + helper.to_s

              base.class_eval <<-"end_eval", __FILE__, __LINE__
                def #{method_name}(*args)
                  options = args.extract_options!
                  use_revision = #{(base.revisable_class.revisable_options.has_many_fixations || {}).include?(r.name)}

                  if current_revision?
                    if use_revision
                      #{r.class_name}.where("#{base.revisable_class.name.underscore}_vid = ?", options[:revision_number] || self.revision_number).scoping do
                        super *(args << options)
                      end
                    else
                      super(*args)
                    end
                  else
                    options[:revision_number] = self.revision_number if use_revision
                    current_revision.send(:#{method_name}, *(args << options))
                  end
                end
              end_eval
            end
          end
        end

 #      base.instance_eval do
 #        base.revisable_class.reflect_on_all_associations(:has_many).each do |r|
 #          unless [:revisions, :branches, base.revision_class_name.tableize.to_sym].include?(r.name)
 #            r.options[:conditions] ||= {}
 #            r.options[:conditions] = Proc.new {"id = #{current_revision? && id || original_id} and plan_vid = #{revisable_number}"}
 #            has_many r.name, r.options
 #          end
 #        end
 #      end
      end

      # With belongs_to_fixations association_belonged_to => :first
      # update the column :association_vid to the current active association revision number
      # at each update.
      # With the option :original only update the association_vid at the time of creation
      # so it will be mapped to the original version through out objects life
      def sync_associations
        belongs_to_fixations = self.class.revisable_options.belongs_to_fixations || {}
        self.clear_association_cache

        self.class.reflect_on_all_associations(:belongs_to).each do |r|
          if (assoc_sym = belongs_to_fixations[r.name]) && self.respond_to?(:"#{r.name}_vid")
            (assoc = self.send r.name) && assoc.respond_to?(:revision_number) or next 

            if (!assoc.current_revision? || self.send(:"#{r.name}_vid").nil?) && (new_record? && assoc_sym == :original || assoc_sym == :first)
              self.send(:"#{r.name}_vid=", assoc.current_revision.revision_number)
            end
          end
        end
      end
    end
  end
end

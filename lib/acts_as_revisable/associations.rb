module WithoutScope
  module ActsAsRevisable
    module Associations
      # With belongs_to_fixations association_belonged_to => :first
      # update the column :association_vid to the current active association revision number
      # at each update.
      # With the option :original only update the association_vid at the time of creation
      # so it will be mapped to the original version through out objects life
      def sync_associations
        belongs_to_fixations = self.class.revisable_options.belongs_to_fixations || {}

        self.class.reflect_on_all_associations(:belongs_to).each do |r|
          if (assoc_sym = belongs_to_fixations[r.name]) && self.respond_to?(:"#{r.name}_vid")
            assoc   = self.send(r.name)
            rev_num = assoc.respond_to?(:revision_number) && assoc.revision_number or next 

            if new_record? && assoc_sym == :original || assoc_sym == :first
              self.send(:"#{r.name}_vid=", assoc.class.find(assoc.id).revision_number)
            end
          end
        end
      end
    end
  end
end

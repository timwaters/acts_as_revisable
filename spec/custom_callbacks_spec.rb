require File.dirname(__FILE__) + '/spec_helper.rb'

describe WithoutScope::ActsAsRevisable do  
  after(:each) do
    cleanup_db
  end
    
  describe "revise callbacks" do
    before(:each) do
      Project.class_eval do
        @@ran_before_revise, @@ran_after_revise = false
        cattr_reader :ran_before_revise, :ran_after_revise
        
        before_revise :verify
        after_revise :audit

        def verify
          @@ran_before_revise = true
        end
        def audit
          @@ran_after_revise = true
        end
      end
      Domestic::Cat.class_eval do        
        @@ran_before_revise, @@ran_after_revise = false
        cattr_reader :ran_before_revise, :ran_after_revise

        before_revise :verify
        after_revise :audit

        def verify
          @@ran_before_revise = true
        end
        def audit
          @@ran_after_revise = true
        end
      end
      @project = Project.create({
        :name => "Rails 3 compat",
        :notes => "some notes"
      })
      @cat = Domestic::Cat.create({
        :name => "Bob",
        :description => "is your uncle."
      })
    end
    it "runs before_revise" do
      @project.update_attribute(:name, "closer")
      @project.name.should eql "closer"
      @project.revision_number.should eql 1
      Project.ran_before_revise.should be_true
      
      @cat.update_attribute(:name, "Robert")
      @cat.name.should eq "Robert"
      @cat.revision_number.should eq 1
      Domestic::Cat.ran_before_revise.should be_true
    end
    it "runs after_revise" do
      @project.update_attribute(:name, "wtf")
      Project.ran_after_revise.should be_true
      @cat.update_attribute(:name, "yay")
      Domestic::Cat.ran_after_revise.should be_true
    end
  end
end

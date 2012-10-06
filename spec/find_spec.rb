require File.dirname(__FILE__) + '/spec_helper.rb'
require 'rails'

describe WithoutScope::ActsAsRevisable do    
  after(:each) do
    cleanup_db
  end
  
  describe "with a single revision" do
    before(:each) do
      @project1 = Project.create(:name => "Rich", :notes => "a note")
      @project1.update_attribute(:name, "Sam")
      @cat = Domestic::Cat.create({
        :name => "Bob",
        :description => "is your uncle."
      })
      @cat.update_attribute(:name, "Robert")
    end
  
    it "should just find the current revision by default" do
      Project.find(:first).name.should == "Sam"
      Domestic::Cat.find(:first).name.should eq "Robert"
    end
    
    it "should accept the :with_revisions options" do
      lambda { Project.find(:all, :with_revisions => true) }.should_not raise_error
      lambda { Domestic::Cat.find(:all, :with_revisions => true) }.should_not raise_error
    end
        
    it "should find current and revisions with the :with_revisions option" do      
      Project.find(:all, :with_revisions => true).size.should == 2
      Domestic::Cat.find(:all, :with_revisions => true).size.should eq 2
    end
        
    it "should find revisions with conditions" do
      Project.find(:all, :conditions => {:name => "Rich"}, :with_revisions => true).should eq [@project1.find_revision(:previous)]
      Domestic::Cat.find(:all, :conditions => {:name => "Bob"}, :with_revisions => true).should eq [@cat.find_revision(:previous)]
    end

		it "should find last revision" do
			@project1.find_revision(:last).should == @project1.find_revision(:previous)
			@cat.find_revision(:last).should eq @cat.find_revision(:previous)
		end
  end
end

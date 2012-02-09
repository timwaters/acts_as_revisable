require File.dirname(__FILE__) + '/spec_helper.rb'

describe WithoutScope::ActsAsRevisable do  
  after(:each) do
    cleanup_db
  end
    
  before(:each) do
    @project = Project.create(:name => "Rich", :notes => "this plugin's author")
    @cat = Domestic::Cat.create(:name => "Pow", :description => "Packs a punch.")
    @project.update_attribute(:name, "one")
    @project.update_attribute(:name, "two")
    @project.update_attribute(:name, "three")
    @cat.update_attribute(:name, "Wop")
    @cat.update_attribute(:name, "Pow Wop")
  end
  
  it "should have a pretty named association" do
    lambda { @project.sessions }.should_not raise_error
    lambda { @cat.cat_revisions }.should_not raise_error
  end
  
  it "should return all the revisions" do
    @project.revisions.size.should == 3
    @cat.revisions.size.should eq 2
  end
end
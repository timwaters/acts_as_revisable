require File.dirname(__FILE__) + '/spec_helper.rb'

describe WithoutScope::ActsAsRevisable, "with reverting" do  
  after(:each) do
    cleanup_db
  end
  
  before(:each) do
    @project = Project.create(:name => "Rich", :notes => "a note")
    @project.update_attribute(:name, "Sam")
    @cat = Domestic::Cat.create({
      :name => "Bob",
      :description => "is your uncle."
    })
    @cat.update_attribute(:name, "Robert")
  end
  
  it "should let you revert to previous versions" do
    @project.revert_to!(:first)
    @project.name.should == "Rich"
    @cat.revert_to!(:first)
    @cat.name.should eq "Bob"
  end
  
  it "should accept the :without_revision hash option" do
    lambda { @project.revert_to!(:first, :without_revision => true) }.should_not raise_error
    @project.name.should == "Rich"
    lambda { @cat.revert_to!(:first, :without_revision => true) }.should_not raise_error
    @cat.name.should eq "Bob"
  end
  
  it "should support the revert_to_without_revision method" do
    lambda { @project.revert_to_without_revision(:first).save }.should_not raise_error
    @project.name.should == "Rich"
    lambda { @cat.revert_to_without_revision(:first).save }.should_not raise_error
    @cat.name.should eq "Bob"
  end
  
  it "should support the revert_to_without_revision! method" do
    lambda { @project.revert_to_without_revision!(:first) }.should_not raise_error
    @project.name.should == "Rich"
    lambda { @cat.revert_to_without_revision!(:first) }.should_not raise_error
    @cat.name.should eq "Bob"
  end
  
  it "should let you revert to previous versions without a new revision" do
    @project.revert_to!(:first, :without_revision => true)
    @project.revisions.size.should == 1
    @cat.revert_to!(:first, :without_revision => true)
    @cat.revisions.size.should eq 1
  end
  
  it "should support the revert_to method" do
    lambda{ @project.revert_to(:first) }.should_not raise_error
    @project.should be_changed
    lambda{ @cat.revert_to(:first) }.should_not raise_error
    @cat.should be_changed
  end
end
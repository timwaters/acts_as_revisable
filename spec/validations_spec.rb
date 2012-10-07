require File.dirname(__FILE__) + '/spec_helper.rb'

describe WithoutScope::ActsAsRevisable, "with validations" do  
  after(:each) do
    cleanup_db
  end
  
  before(:each) do
    @post = Post.create(:name => 'a post', :title => 'post title', :author => 'bob')
    @foo = Foo.create(:name => 'a foo')
    
  end
  
  describe "unique fields" do
    it "should raise uniqueness errors" do
      lambda {Post.create!(:title => 'post title')}.should raise_error(ActiveRecord::RecordInvalid, 'Validation failed: Title has already been taken')
      lambda {
        Post.create!(:name => 'post 2', :title => 'title 2', :author => 'tintin', :tag => 'test')
        Post.create!(:name => 'post 3', :title => 'title 3', :author => 'tintin', :tag => 'test')
      }.should raise_error(ActiveRecord::RecordInvalid, 'Validation failed: Author has already been taken')
    end

    it "should allow revisions" do
      lambda {@post.revise!; @post.revise!}.should_not raise_error
    end    
  end
  
  describe "unique fields with validation scoping off" do
    it "should not allow revisions" do
      lambda {@foo.revise!; @foo.revise!}.should raise_error
    end    
  end
end

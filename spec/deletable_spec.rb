require File.dirname(__FILE__) + '/spec_helper.rb'

describe WithoutScope::ActsAsRevisable::Deletable do    
  
  Domestic::Cat.class_eval do
    acts_as_revisable do
      revision_class_name "Domestic::CatRevision"
      on_delete :revise
    end
  end
  after(:each) do
    cleanup_db
  end
  
  before(:each) do
    @person = Person.create(:name => "Rich", :notes => "a note")
    @person.update_attribute(:name, "Sam")
    @cat = Domestic::Cat.create({
      :name => "Bob",
      :description => "is your uncle."
    })
    @cat.update_attribute(:name, "Robert")
  end
  
  it "should store a revision on destroy" do
    lambda{ @person.destroy }.should change(OldPerson, :count).from(1).to(2)
    lambda{ @cat.destroy }.should change(Domestic::CatRevision, :count).from(1).to(2)
  end
end
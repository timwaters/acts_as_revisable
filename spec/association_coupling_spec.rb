require File.dirname(__FILE__) + '/spec_helper.rb'

describe WithoutScope::ActsAsRevisable do  
  after(:each) do
    cleanup_db
  end
  
  describe "with mapped to original" do
    before(:each) do
      @plan = Plan.create(:name => "Rich", :price => 10)
      @subscription = @plan.subscriptions.create(:name => "Frodo")
    end

    it "should map to the correct version of supper class" do
      @subscription.plan_vid.should == @plan.revision_number
      lambda { @plan.update_attributes(:price => 20) }.should change(@plan, :revision_number).by(1)
      @subscription.plan(:reload => true).revision_number.should == @plan.find_revision(:previous).revision_number
    end

    it "should filter child assocations returned by parent's version" do
      @plan.subscription_ids.should include @subscription.id
      lambda { @plan.update_attributes!(:price => 20) }.should_not raise_error
      @plan.subscriptions.should_not include @subscription.id
      @plan.find_revision(:previous).subscription_ids.should include @subscription.id
    end
  end

  describe "with mapped to current" do
    it "should map to the current version of supper class" do
    end

    it "should return all subclasses" do
    end

    it "should be the default option" do
    end
  end

  describe "with mapped to first" do
    it "should map the current version of parent to the subclass when creating a new instance" do
    end

    it "should filter child assocations returned by parent's version" do
    end
  end

  describe "with option clone_associations" do
    it "should revise all sub class instances when parent is revised" do
    end

    it "should revise all instances as an atomic transaction if specified" do
    end
  end
end

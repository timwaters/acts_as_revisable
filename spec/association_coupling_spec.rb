require File.dirname(__FILE__) + '/spec_helper.rb'

describe WithoutScope::ActsAsRevisable do  
  after(:each) do
    cleanup_db
  end
  
  describe "with mapped to original" do
    before(:each) do
      @plan = Plan.create(:name => "Yearly", :price => 10)
      @subscription = @plan.type_one_subscriptions.create(:name => "Frodo")
    end

    it "should map to the original version when updating" do
      @subscription.plan_vid.should == @plan.revision_number
      lambda { @plan.update_attributes(:price => 20) }.should change(@plan, :revision_number).by(1)
      lambda { @subscription.update_attributes(:name => "Merry") }.should change(@subscription, :revision_number).by(1)
      @subscription.revised_plan.revision_number.should == @plan.revision_number - 1
      @subscription.find_revision(:previous).revised_plan.revision_number.should == @plan.revision_number - 1
    end

    it "should filter has-many assocations by parent's version for 'collection_ids'" do
      @plan.revised_type_one_subscription_ids.should include @subscription.id
      lambda { @plan.update_attributes!(:price => 20) }.should change(@plan, :revision_number).by(1)
      @plan.revised_type_one_subscription_ids.should_not include @subscription.id
      @plan.find_revision(:previous).revised_type_one_subscription_ids.should include @subscription.id
    end

    it "should filter has-many assocations by parent's version for 'collection'" do
      @plan.revised_type_one_subscriptions.map(&:id).should include @subscription.id
      lambda { @plan.update_attributes!(:price => 20) }.should change(@plan, :revision_number).by(1)
      @plan.revised_type_one_subscriptions.map(&:id).should_not include @subscription.id

      lambda { @subscription.update_attributes(:name => "Merry") }.should change(@subscription, :revision_number).by(1)
      @plan.revised_type_one_subscriptions.map(&:id).should_not include @subscription.id
      @plan.find_revision(:previous).revised_type_one_subscriptions.map(&:id).should include @subscription.id
    end
  end

  describe "with mapped to first" do
    before(:each) do
      @plan = Plan.create(:name => "Yearly", :price => 10)
      @subscription = @plan.type_two_subscriptions.create(:name => "Sam")
    end

    it "should map to the active association version at the time of instance creation" do
      @subscription.plan_vid.should == @plan.revision_number
      lambda { @plan.update_attributes(:price => 20) }.should change(@plan, :revision_number).by(1)
      @subscription.revised_plan.revision_number.should == @plan.revision_number - 1

      lambda { @subscription.update_attributes(:name => "Merry") }.should change(@subscription, :revision_number).by(1)
      @subscription.revised_plan.revision_number.should == @plan.revision_number
      @subscription.find_revision(:previous).revised_plan.revision_number.should == @plan.revision_number - 1
    end

    it "should filter has-many assocations by parent's version for 'collection_ids'" do
      @plan.revised_type_two_subscription_ids.should include @subscription.id
      lambda { @plan.update_attributes!(:price => 20) }.should change(@plan, :revision_number).by(1)
      @plan.revised_type_two_subscription_ids.should_not include @subscription.id
      @plan.find_revision(:previous).revised_type_two_subscription_ids.should include @subscription.id
    end

    it "should filter has-many assocations by parent's version for 'collection'" do
      @plan.revised_type_two_subscriptions.map(&:id).should include @subscription.id
      lambda { @plan.update_attributes!(:price => 20) }.should change(@plan, :revision_number).by(1)
      @plan.revised_type_two_subscriptions.map(&:id).should_not include @subscription.id

      lambda { @subscription.update_attributes(:name => "Merry") }.should change(@subscription, :revision_number).by(1)
      @plan.revised_type_two_subscriptions.map(&:id).should include @subscription.id
      @plan.find_revision(:previous).revised_type_two_subscriptions.map(&:id).should_not include @subscription.id
    end
  end

  describe "without version mapping enabled (default)" do
    before(:each) do
      @plan = Plan.create(:name => "Yearly", :price => 10)
      @subscription = @plan.default_subscriptions.create(:name => "Pipin")
    end

    it "should map to current active association version" do
      @subscription.plan_vid.should == nil
      lambda { @plan.update_attributes(:price => 20) }.should change(@plan, :revision_number).by(1)
      lambda { @subscription.update_attributes(:name => "Merry") }.should change(@subscription, :revision_number).by(1)

      @subscription.revised_plan.revision_number.should == @plan.revision_number
      @subscription.find_revision(:previous).revised_plan.revision_number.should == @plan.revision_number
    end

    it "should return all has-many associations" do
      @plan.revised_default_subscription_ids.should include @subscription.id
      lambda { @plan.update_attributes!(:price => 20) }.should change(@plan, :revision_number).by(1)
      @plan.revised_default_subscription_ids.should include @subscription.id
      @plan.find_revision(:previous).revised_default_subscription_ids.should include @subscription.id
    end
  end

  describe "with option clone_associations" do
    it "should revise all sub class instances when parent is revised" do
    end

    it "should revise all instances as an atomic transaction if specified" do
    end
  end
end

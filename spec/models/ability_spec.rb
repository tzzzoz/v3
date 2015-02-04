require 'spec_helper'
require "cancan/matchers"

describe Ability do

  context "when user is a superadmin" do
    
    let(:superadmin) { User.make(:superadmin) }
    
    it "should be able to manage all if the user is a superadmin" do
      ability = Ability.new(superadmin)
      ability.should be_able_to(:manage, :all)
    end

    it "should be able to create superadmin users if he's superadmin" do
      ability = Ability.new(superadmin)
      ability.can?(:manage, superadmin).should be_true
    end

  end # context

  context "when user is an editor_admin" do

    let(:editor_admin_user) { User.make(:editor_admin) }

    it "should be able to manage users" do
      ability = Ability.new(editor_admin_user)
      ability.should be_able_to(:manage, User)
    end

    it "should be able to create editor_user users" do
      ability = Ability.new(editor_admin_user)
      ability.can?(:manage, User.make(:editor_user)).should be_true
    end

    it "should not be able to create editor_admin users" do
      ability = Ability.new(editor_admin_user)
      ability.can?(:manage, editor_admin_user).should be_false
    end

    it "should not be able to create superadmin users" do
      ability = Ability.new(editor_admin_user)
      ability.can?(:manage, User.make(:superadmin)).should be_false
    end

    it "should not be able to create provider_admin users" do
      ability = Ability.new(editor_admin_user)
      ability.can?(:manage, User.make(:provider_admin)).should be_false
    end

    it "should not be able to create provider_user users" do
      ability = Ability.new(editor_admin_user)
      ability.can?(:manage, User.make(:provider_user)).should be_false
    end

  end # context

  context "when user is a provider_admin" do
    
    let(:provider_admin_user) { User.make(:provider_admin) }
    
    it "should be able to manage users" do
      ability = Ability.new(provider_admin_user)
      ability.should be_able_to(:manage, User)
    end

    it "should be able to create provider_user users" do
      ability = Ability.new(provider_admin_user)
      ability.can?(:manage, User.make(:provider_user)).should be_true
    end

    it "should not be able to create provider_admin users" do
      ability = Ability.new(provider_admin_user)
      ability.can?(:manage, provider_admin_user).should be_false
    end

    it "should not be able to create superadmin users" do
      ability = Ability.new(provider_admin_user)
      ability.can?(:manage, User.make(:superadmin)).should be_false
    end

    it "should not be able to create provider_admin users" do
      ability = Ability.new(provider_admin_user)
      ability.can?(:manage, User.make(:provider_admin)).should be_false
    end

    it "should not be able to create editor_user users" do
      ability = Ability.new(provider_admin_user)
      ability.can?(:manage, User.make(:editor_user)).should be_false
    end

  end # context

  context "when user is an editor_user (default user)"

  let(:editor_user) { User.make }
  
  it "should not be able to manage all if the user" do
    ability = Ability.new(editor_user)
    ability.should_not be_able_to(:manage, :all)
  end

  it "should be able to read all" do
    ability = Ability.new(editor_user)
    ability.should be_able_to(:read, :all)
  end

end
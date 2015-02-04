require 'spec_helper'

describe User do

  describe "A User" do

    it { should belong_to :title }
    it { should belong_to  :country }
    it { should have_many  :light_boxes }
    it { should have_many  :search_provider_group_names }
    it { should have_many  :request_to_providers }
    it { should have_many  :statistics }
    it { should have_one   :setting }
    it { should have_many  :saved_searches }

    it { should validate_presence_of :email }
    it { should validate_presence_of :login }

    # TODO: remove when authlogic has been updated for Rails 3 => save(false)
    before(:all) do
      ActiveSupport::Deprecation.silenced = true
    end
    
    before(:each) do
      activate_authlogic
      @current_user = User.make
      UserSession.create(@current_user)
    end
  
    it "should validates uniqueness of email" do
      user = User.make
      should validate_uniqueness_of :email
    end

    it "should validates uniqueness of login" do
      user = User.make
      should validate_uniqueness_of :login
    end

    describe "Defined class methods" do

      it "should respond to current" do
        User.should respond_to(:current)
      end

      it "should fetch the current user" do
        User.current.should == @current_user
      end
    end

    it "should have a full_name method" do
      user = User.make
      user.full_name.should == "#{user.first_name} #{user.last_name}"
    end

  end # describe

  context "A new User" do
    it "should have a first light_box" do 
      u = User.make
      u.light_boxes.count.should == 1
    end

    it "should have a setting" do 
      u = User.make
      u.setting.should_not be_nil
    end

  end
  
  # TODO: fix it, returns 1
  # context "When destroying a User" do
  #   it "should destroy his light_boxes" do 
  #     u = User.make ; user_id = u.id
  #     u.destroy
  #     LightBox.count("user_id=#{user_id}").should == 0
  #   end
  # end
  
  context "The roles definition" do
    before(:each) do
      @user = User.make
      @user.clear_roles!
    end

    it "should have 5 roles" do
      User::ROLES_MASK.size.should == 5
    end

    it "should have editor_user role for a default user" do
      default_user = User.make
      default_user.roles_mask.should == 4
    end

    it "should have roles_mask set to 1 for superadmin" do
      @user.add_role!('superadmin')
      @user.roles_mask.should == 1
    end

    it "should have roles_mask set to 2 for editor_admin" do
      @user.add_role!('editor_admin')
      @user.roles_mask.should == 2
    end

    it "should have roles_mask set to 4 for editor_user" do
      @user.add_role!('editor_user')
      @user.roles_mask.should == 4
    end

    it "should have roles_mask set to 8 for provider_admin" do
      @user.add_role!('provider_admin')
      @user.roles_mask.should == 8
    end

    it "should have roles_mask set to 16 for editor_user" do
      @user.add_role!('provider_user')
      @user.roles_mask.should == 16
    end   
  end # context

  context 'When given valid attributes' do

    it "should create a valid new instance" do
      user = User.make
      user.should be_valid
    end

    it "should create a user without a first_name" do
      user = User.new(User.plan.except(:first_name))
      user.should be_valid
    end

    it "should create a user without a last_name" do
      user = User.new(User.plan.except(:last_name))
      user.should be_valid
    end

    it "should lowercase user login" do
      user = User.make(:login => 'RICP')
      user.login.should == 'ricp'
    end

    it "should lowercase user email" do
      user = User.make(:login => 'RICP@NUXOS.FR')
      user.login.should == 'ricp@nuxos.fr'
    end


  end # context

  context 'When given invalid attributes' do
    it "should not be created with an invalid email address" do
      user = User.make_unsaved(:email => "BAD")
      user.should_not be_valid
      user.errors[:email].should include "should look like an email address."
      user.errors[:email].should include  "is invalid"  
    end
  end # context

  context 'When given missing attributes' do
    it "should not be created without a login" do
      user = User.new(User.plan.except(:login))
      user.should_not be_valid
      user.errors[:login].should include "is too short (minimum is 6 characters)"
      user.errors[:login].should include "should use only letters, numbers, spaces, and .-_@ please."
      user.errors[:login].should include "can't be blank"
      user.errors[:login].should include "is invalid"
    end

    it "should not be created if login is less than 6 characters" do
      user = User.make_unsaved(:login => 's')
      user.should_not be_valid
      user.errors[:login].should include "is too short (minimum is 6 characters)"
    end

    it "should not be created without a password" do
      user = User.new(User.plan.except(:password))
      user.should_not be_valid
      user.errors[:password].should include "is too short (minimum is 6 characters)"
    end

    it "should not be created without a password confirmation" do
      user = User.new(User.plan.except(:password_confirmation))
      user.should_not be_valid
      user.errors[:password_confirmation].should include "is too short (minimum is 6 characters)"
    end

    it "should not be created when password is different from password confirmation" do
      user = User.make_unsaved(:password => "password", :password_confirmation => "other password")
      user.should_not be_valid
      user.errors[:password].should include "doesn't match confirmation" 
    end

    it "should not be created if password is less than 6 characters" do
      user = User.make_unsaved(:password => 's', :password_confirmation => 's')
      user.should_not be_valid
      user.errors[:password].should include "is too short (minimum is 6 characters)"
    end
  end # context

end

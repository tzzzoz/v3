class UserPasswordResetsController < ApplicationController
  before_filter :login_not_required
  skip_before_filter :login_required

  layout 'user_sessions'

  def new
    render
  end

  def create
    @user = User.find_by_email(params[:email])
    if @user
      @user.deliver_password_reset_instructions!
      flash[:notice] = I18n.t 'instructions_mailed'
      redirect_to root_url
    else
      flash[:notice] = I18n.t 'user_mail_not_found'
      render :action => :new
    end
  end

  def edit
    render
  end

  def update
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    if @user.save
      flash[:notice] = I18n.t 'password_updated'
      redirect_to home_url
    else
      flash[:notice] = @user.errors.on(:password)
      redirect_to password_reset_url + '?id=' + params[:id]
    end
  end

  
end

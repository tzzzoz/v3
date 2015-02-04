class UsersController < ApplicationController

  def index
    render :layout => 'simple'
  end

  def show
    @user = User.find(params[:id])

    respond_to do |format|
     format.xml { render :xml => @user }
    end
  end

  def loggin
    @user = User.where(:login => params[:login])

    respond_to do |format|
      format.xml { render :xml => @user }
      format.json { render json: @user }
    end
  end

  def export_xls
   send_file USERS_LIST_FILE, :disposition => 'attachment'
  end

end

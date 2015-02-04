# To change this template, choose Tools | Templates
# and open the template in the editor.

module AuthenticationMethods
  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.user
    @current_user
  end

  def login_required
    unless current_user
      flash[:notice] = "Vous devez être connecté pour voir cette page"
      redirect_back_or_default(new_user_session_path)
      return false
    end
  end

  def adm_login_required
    unless current_user.is_provider_admin? || current_user.is_superadmin?
      flash[:notice] = "login incompatible"
      redirect_back_or_default(new_user_session_path)
      return false
    end
  end

  def login_not_required
    if current_user
      flash[:notice] = "You must be logged out to access this page"
      return false
    end
  end

  def logged_in?
    # TODO : Damien seems used in resful_ACl for logging
    !!current_user
  end

  def store_previous_location
    session[:return_to] = request.env["HTTP_REFERER"]
  end

  def store_location
    session[:return_to] = request.env['REQUEST_URI']
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

	def logout_keeping_session!
	  # TODO : Damien seems used only in new user registration and outdated
    @current_user = false
    session[:user_id] = nil
	end

    
end

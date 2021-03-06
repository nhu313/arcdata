class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_user, :current_user_session

  before_filter :require_valid_user!

  #check_authorization

  rescue_from CanCan::AccessDenied do |exception|
    raise exception and return if Rails.env.test?
    begin
      respond_to do |fmt|
        fmt.html{ flash[:error] = "You are not authorized to access that page."; redirect_to :back }
        fmt.pdf{ flash[:error] = "You are not authorized to access that page."; redirect_to :back }
        fmt.json{ head :forbidden }
        fmt.ics{ head :forbidden }
      end
    rescue ActionController::RedirectBackError
      redirect_to root_path
    end
  end

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = Roster::Session.find
  end

  def current_user
    return @current_user if defined?(@current_user)

    @current_user = current_user_session && current_user_session.person
  end

  def require_valid_user!(return_to=url_for(only_path: false))
    #puts "Setting redirec to #{return_to}"
    unless current_user_session
      session[:redirect_after_login] = return_to if return_to
      respond_to do |fmt|
        fmt.html{ redirect_to new_roster_session_path }
        fmt.pdf{ redirect_to new_roster_session_path }
        fmt.json{ head :unauthorized }
        fmt.ics{ head :unauthorized }
      end
    else 
      true
    end
  end

end

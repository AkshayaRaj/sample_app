module SessionsHelper

  def log_in(user)
    session[:user_id]=user.id
    #log in a user by assigning the user id to a valid key in the session hash
  end

  def log_out
    forget(current_user)
    session.delete(:user_id)
    #delete the user id from the session hash. This will implicate logging out of the user.
    @current_user=nil
  end



  def current_user
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.signed[:user_id])
      
      user = User.find_by(id: user_id)
      if user && user.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end






  def logged_in?
    #if the current user is logged in then return true.
    !current_user.nil?
  end


  def remember(user)
    user.remember
    cookies.permanent.signed[:user_id]=user.id
    cookies.permanent[:remember_token]=user.remember_token
  end

  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

end

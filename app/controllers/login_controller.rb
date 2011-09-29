class LoginController < ApplicationController
  layout "moneyonrails"
  auto_complete_for :contact, :name
  skip_before_filter :login_required
  # If you want "remember me" functionality, add this before_filter to Application Controller
  #before_filter :login_from_cookie

  # say something nice, you goof!  something sweet.
  def index
    redirect_to(:action => 'login') and return unless logged_in?
    
    @user = current_user
  end

  def login
    return unless request.post?
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      redirect_back_or_default(:controller => '/home', :action => 'index')
      flash[:notice] = "Logged in successfully"
    else
      flash[:warning] = "Username and password don't match or account is not activated"    
    end
    
  end

  def signup
    return unless request.post?
    user = User.new(params[:user])
    if user.save
      flash[:notice] = "Thanks for signing up! You should receive an email shortly to activate your account."
      render :action => :login
    else
      render :action => 'signup'
    end
  end
  
  def logout
    #self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default(:controller => '/login', :action => 'login')
  end
  
  def update
    redirect_to(:action => 'login') and return unless logged_in?
    if(!current_user.admin? && params[:find][:id] != current_user.id.to_s)
      flash[:warning] = 'Illegal Access Attempt'
      redirect_to(:action => 'signup') and return
    end
    
    user = User.find(params[:find][:id])
    if(params[:user][:password] == "")
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end
    user.update_attributes(params[:user])
    if user.save
      flashInit(:notice)
      flash[:notice] << 'User Update Successful <br />'
    else
      flashInit(:warning)
      flash[:warning] << user.errors.full_messages.to_s << '<br />'
    end
    redirect_to :action => :index
  end
  
  def activate
  @user = User.find_by_activation_code(params[:id])
  if @user and @user.activate
    self.current_user = @user
    redirect_back_or_default(:controller => '/login', :action => 'login')
    flash[:notice] = "Your account has been activated." 
  end
  
end
end

module LoginHelper

  def setupVars
    
    if(@user)
      @name = @user.name
      @email = @user.email
      @login = @user.login
      @id = @user.id
    else
      redirect_to(:action => 'login')
    end
    
  end
  

end

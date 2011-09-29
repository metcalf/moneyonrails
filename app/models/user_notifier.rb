class UserNotifier < ActionMailer::Base
  def signup_notification(user)
    setup_email(user)
    @subject    += 'Please activate your new account'
    @recipient = user.email
    @body[:url]  = SITE_ROOT + "account/activate/#{user.activation_code}"
  end
  
  def activation(user)
    setup_email(user)
    @subject    += 'Your account has been activated!'
    @body[:url]  = SITE_ROOT
  end
  
  def alert(alertObj)
    @from = "alerts@throughawall.com"
    @sent_on = Time.now
    @recipients = alertObj.email
    @subject = alertObj.subject
    @body[:alert] = alertObj.body
    @body[:user] = alertObj.user
  end
 
  protected
  def setup_email(user)
    @recipients  = "#{user.email}"
    @from        = "webmaster@throughawall.com"
    @subject     = SITE_NAME + " "
    @sent_on     = Time.now
    @body[:user] = user
  end
end

class Alert < ActiveRecord::Base
  belongs_to :alert_type
  belongs_to :user
  has_many :alert_parameters, :dependent => :destroy
  
  # All verification functions are prefaced with "check" and end in "?"
  def checkChanged?
    return true
  end
  
  def checkForeignChanged?
    return User.current_user != self.user
  end
  
  def checkGreater?
    checkInequality?(:>)
  end
  
  def checkLess?
    checkInequality?(:<)
  end
  
  def checkInequality?(fxn)
    User.current_user.view = true
    (Account.find(self.parameters[:account_id]).amount(self.parameters[:days])).send(fxn, self.parameters[:value]) 
  end

  def email
    self[:email] ? self[:email] : self.user.email
  end
  
  def parameters
    if(!@params)
      @params = {}
      self.alert_parameters.each do |param|
        params[param.alert_parameter_type.name] = param.value
      end
    end
    @params
  end
  
  def dispatch?
    fxn = "check" + self.alert_type.function + "?"
    if(self.respond_to(fxn))
      return self.send(fxn)
    else
      return false
    end
  end
  
  def body
    self.alert_type.body(self.parameters)  
  end
  
  def subject
   self.alert_type.subject(self.alert_parameters)
  end
  
end

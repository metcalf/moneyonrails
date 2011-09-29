# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_moneyonrails_session_id'
  include AuthenticatedSystem
  before_filter :login_required
  before_filter { |c| User.current_user = c.current_user }
  
  layout "moneyonrails"
 
  def auto_complete_for_account_name
    # Determine how many results to retrieve... ensure that all results of the same name are returned
    counts = Group.find_by_sql("SELECT COUNT(*), name FROM accounts WHERE LOWER(name) LIKE '%#{params[:account][:name].downcase}%' GROUP BY name ORDER BY name ASC")
    num = 0
    max = 10
    names = []
    counts.each do |count| 
      if(num >  max)
        break
      else
         params = count.attributes
         num = num + params["COUNT(*)"].to_i
         names << params["name"]
      end
    end 
    
    accts = Account.find(:all, 
      :conditions => "name IN "+'("' + names.join('","') + '")', 
      :order => "name ASC",
      :limit => num < 20 ? num : 20)

    groups = Group.find(:all, :conditions => [ "LOWER(name) LIKE ?",
        '%' + params[:account][:name].downcase + '%'],
        :limit => 4)
    
    @results = accts + groups

    render :partial => 'accounts_complete'
    
  end
 
  protected
  
  def flashInit(key)
    if(flash[key] == nil)
      flash[key] = ""
    end
  end
 
end

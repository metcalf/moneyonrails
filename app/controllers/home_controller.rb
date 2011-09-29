class HomeController < ApplicationController

  auto_complete_for :account, :name

def index
  @alerts = Alert.find(:all, :conditions => ['user_id = ?', current_user.id])
end

def addAlert
  alert = Alert.new
  alert.email = current_user.email
  if(params[:type] == "changed")
    alert.alert_type_id = 3
    if alert.save
      AlertParameter.create( :alert_id => alert.id, :value => params[:account][:name], :alert_parameter_type_id => 3)
    end
  elsif(params[:type] == "inequality")
    if(params[:mode] == ">")
      alert.alert_type_id = 1
    else
      alert.alert_type_id = 2
    end
    if alert.save
      params[:account][:id] = Account.find_by_name_and_user_id(params[:account][:name], current_user.id)
      AlertParameter.create( :alert_id => alert.id, :value => params[:account][:id], :alert_parameter_type_id => 2 )
      AlertParameter.create( :alert_id => alert.id, :value => params[:account][:name], :alert_parameter_type_id => 3 )
      AlertParameter.create( :alert_id => alert.id, :value => params[:account][:amount], :alert_parameter_type_id => 1 )
    end
  else
  end
  redirect_to :action => :index
end

end

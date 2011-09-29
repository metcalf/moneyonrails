class EventObserver < ActiveRecord::Observer
  
  def after_saveOld(event)
    # find any alerts that should be triggered
    users = event.users
    users.each do |user|
      alerts = Alert.find_by_user_id(user.id)
      return unless alerts != nil && alerts.respond_to?(:each)
      alerts.each do |alert|
        # check if triggered
        if(alert.dispatch?)
          UserNotifier.deliver_alert(alert)
        end
      end
    end
  end
end

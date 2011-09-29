class AdminController < ApplicationController

def batchUsers
  User.transaction do Account.transaction do 
    params[:user].each_value do |userParam|
      user = User.new(userParam)
      if user.save
        keys = params[:account].keys.sort
        keys.each do |key|
          acctParam = params[:account][key]
          parent = Account.find(:first, :conditions => {:name => acctParam[:parent], :user_id => user.id} ) 
          if parent != nil
            setAccount(acctParam[:name], user, parent, acctParam[:users]) 
          else
            flashInit(:warning)
            flash[:warning] << 'Parent Account not found... aborting <br />' + acctParam.inspect + '<br />' + user.accounts.inspect + '<br />'
            raise ActiveRecord::RecordNotSaved
          end
        end
      else
        flashInit(:warning)
        flash[:warning] << user.errors.full_messages.to_s << '<br />'
        ActiveRecord::RecordNotSaved
      end
    end
  end end
  redirect_to :action => 'index'
end

private

def setAccount(name, user, parent, authUsers)
  master = User.current_user
  User.current_user = user
  acct = Account.new({ :name => name, :user_id => user.id, :parent_id => parent.id, :deleteLock => 0, :parentLock => 0, :account_type_id => NORM_ACCT })
  if acct.save
    acct.setAuthorized(authUsers)
  else  
    flashInit(:warning)
    flash[:warning] << user.errors.full_messages.to_s << '<br />'
    raise ActiveRecord::RecordNotSaved
  end
  User.current_user = master
end
  
end

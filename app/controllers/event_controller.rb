class EventController < ApplicationController
  
  def edit
    if(params[:id])
      @edit = Event.find(params[:id])
    end
    render :partial => 'edit'
  end
  
  def add
    render :partial => 'edit'
  end
  
  def update
    return unless request.post?
    edit = Event.find(params[:event][:id])

    params[:event][:user_id] = edit.user_id

    setEvent(params[:event], params[:account], params[:delete], edit)
    Event.last_update = Time.now.to_f
    redirect_to :action => 'index'
  end
  
  def create

    return unless request.post?
    
    params[:event][:user_id] = current_user.id
    event = Event.new
    
    setEvent(params[:event], params[:account], params[:delete], event)
    Event.last_update = Time.now.to_f
    redirect_to :action => 'index' 
  end

  def delete
    Event.find(params[:id]).destroy
  end

  def index
    session[:numActs] = 0;
    if(!session[:event_results] || !session[:estimate_results] || 
      (!session[:event_time] || session[:event_time] < Event.last_update) || 
      params[:filter])
      filter
    end
  end
  
  # :amount_max
  # :amount_min
  # :date_max
  # :date_min
  # :name LIKE result
  def filter
    conditions = ["isEstimate = ?"]
    values = [ 0 ]
    if(params[:filter])
      session[:filter] = params[:filter]
    end
    if(session[:filter])
      if(session[:filter][:date_max])
        conditions << "moment <= ?"
        values << session[:filter][:date_max]
      end
      if(session[:filter][:date_min])
        conditions << "moment >= ?"
        values << session[:filter][:date_min]
      end
      if(session[:filter][:name] && session[:filter][:name] != "") 
        conditions << "name LIKE ?"
        values << "%" + session[:filter][:name] + "%"
      end
    end
    conditions = values.insert(0, conditions.join(" AND "))

    
    session[:event_results] = getResults(conditions, params[:event_page])
    conditions[1] = 1
    session[:estimate_results] = getResults(conditions, params[:estimate_page])
    
    session[:event_time] = Time.now.to_f
    #raise session[:event_time].to_s + "    " + Event.last_update.to_s
  end
  
  def getResults(conditions, page)
    finds = { :order => 'moment DESC', :conditions => conditions , :page => page }
    return Event.paginate(:all, finds)#.select do |evt|
#      if(session[:filter] && 
#        ((session[:filter][:amount_min] && session[:filter][:amount_min] == "") ||
#        (session[:filter][:amount_max] && session[:filter][:amount_max] == "")))
#        
#        amt = evt.amount
#        if(session[:filter][:amount_min] && session[:filter][:amount_min] != "" && session[:filter][:amount_min].to_f > amt)
#          false
#        elsif(session[:filter][:amount_max] && session[:filter][:amount_max] != "" && session[:filter][:amount_max].to_f < amt)
#          false
#        else
#          true
#        end
#      else
#        true
#      end
#    end
  end

  def clear
    session[:filter] = nil
    session[:event_time] = nil
    redirect_to :action => 'index'
  end

  private  
  
  def setEvent(eventParam, accountParam, deleteParam, event) 
    begin Event.transaction do EventsAccount.transaction do 
      event.update_attributes(eventParam)
      
      # TODO make this more efficient? maybe a "has been touched" flag of some sort?
      event.events_accounts.each do |evtAcct|
        if(evtAcct.account.link?)
          evtAcct.amount = 0
          evtAcct.save
        end
      end
      
      evtAccts = Array.new
      accountParam.each_value do |param|
        evtAccts = evtAccts + getEventAccounts(param, event)
      end
      
      event.events_accounts = evtAccts
      event.reload
      if(!event.save  || !event.balanced?)
        flashInit(:warning)
        flash[:warning] << event.errors.full_messages.to_s << '<br />'
        raise ActiveRecord::RecordNotSaved
      end
      
    end end # End transactions
    rescue ActiveRecord::RecordNotSaved
      # Do nothing
      flash[:warning] << 'Transaction was not saved <br />'
    else
      flashInit(:notice)
      flash[:notice] << 'Transaction was successfully updated. <br />'
    end
  end
  
  def getEventAccounts(param, event)  
    
    evtAccts, evtAcct, acct = [], nil, nil
    
    if(param[:id] != "")
      event.events_accounts.each do |temp|
        if  temp.id == param[:id]
          evtAcct = temp
          if evtAcct.account_id == param[:account_id]
            acct = evtAcct.account
          end
          break
        end
      end
    end
    
    evtAcct ||= EventsAccount.new()
    acct ||= Account.find(param[:account_id])
    
    param[:amt] = param[:amt].to_f
    
    if(acct.user_id != current_user.id && !acct.link?)
      evtAccts = evtAccts + getEventAccounts(linkParam(param[:amt], param[:is_credit].include?("1"), Account.find_link_out(acct.user), event), event)
      evtAccts = evtAccts + getEventAccounts(linkParam(param[:amt], !param[:is_credit].include?("1"), Account.find_link_in(acct.user), event), event)
    end
    
    evtAcct.update_attributes( { :account_id => acct.id, :amount => param[:amt], :is_credit => param[:is_credit] } )
    evtAccts << evtAcct
    
    return evtAccts
  end 
  
  def linkParam(amt, credit, account, event)
    evtAcct = nil
    event.events_accounts.each do |temp|
      if temp.account_id == account.id
        evtAcct = temp
        id = evtAcct.id
        amt = evtAcct.amount + amt
        break
      end
    end
    if(evtAcct == nil)
      id = ""
    end
    
    { :account_id => account.id, :is_credit => (credit ? "1" : "0"), :amt => amt, :id => id  }
  end
  
end

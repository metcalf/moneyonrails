# comment
class Event < ActiveRecord::Base 
  include ActsAsProtected
  
  has_many :events_accounts, :dependent => :destroy
  
  belongs_to :user
    
  validates_presence_of :user_id, :moment, :name
  validates_length_of :name, :in => 3..80
  
  def self.last_update
    @@last_update ||= Time.now.to_f
  end
  
  def self.last_update=(time)
    if(time.respond_to?(:to_f))
      @@last_update = time.to_f
    end
  end
  
  # TODO Cache debits and credits
  def debits
    result = self.events_accounts.select do |evtAcct|
      if(!evtAcct.credit?)
        true
      else
        false
      end
    end
    return result
  end
  
  def credits
    result = self.events_accounts.select do |evtAcct|
      if(evtAcct.credit?)
        true
      else
        false
      end
    end
    return result
  end
   
   
  def balanced?
    amts = {}
    begin
      # TODO could the calls to deb.account.user_id or cred.account.user_id fail if the accounts somehow became inaccessible?
      User.current_user.view = true
      self.debits.each do |deb|
        amts[deb.account.user_id] ||= 0
        amts[deb.account.user_id] = amts[deb.account.user_id] + deb.amount
      end
      self.credits.each do |cred|
        if(!amts[cred.account.user_id])
          #errors.add_to_base "Debits and Credits are not equal!"
          return false
        end
        amts[cred.account.user_id] = amts[cred.account.user_id] - cred.amount
      end
    rescue
      raise $!
    ensure
      User.current_user.view = false
    end
    amts.each_value do |item|
      if(item.abs > 0.001)
        #errors.add_to_base "Debits and Credits are not equal!"
        return false
      end
    end
    return true
  end
 
 def balanced!
   raise DebCredError unless self.balanced? 
 end
  
  def current?
    (self.moment <= Date.today)
  end

  def amount
    debit = 0
    self.debits.each do |deb|
        debit = debit + deb.amount 
    end 
    debit
  end
  
  def localAmount
    debit = 0
    self.debits.each do |deb|
      if deb.account.user_id == User.current_user.id
        debit = debit + deb.amount 
      end
    end 
    debit
  end
  
  def debits_old
    EventsAccount.find_all_by_event_id_and_is_credit(self.id, 0)
  end
  
  def credits_old
    EventsAccount.find_all_by_event_id_and_is_credit(self.id, 1)    
  end
  
  def Event.allowed?(record)
    record.events_accounts.each do |evtAcct|
        if(EventsAccount.allowed?(evtAcct))
          return true
        end
      end
      return false
  end
    
  def users
    users = []
    self.events_accounts.each do |evtAcct|
      users << evtAcct.account.user
    end
    users
  end
   
end
 
class DebCredError < StandardError
end
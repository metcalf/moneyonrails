class EventsAccount < ActiveRecord::Base
  include ActsAsProtected
  
  belongs_to :account
  belongs_to :event
  
  validates_numericality_of :amount
  validates_inclusion_of :is_credit, :in => 0..1
  validates_presence_of :account_id , :event_id
  
  
  def credit?
    self.is_credit == 1
  end
  
  def name
    if self.account
      self.account.name
    else
      "Unknown Account"
    end 
  end
  
  def self.allowed?(record)
    record.account != nil && Account.allowed?(record.account)
  end
  
end

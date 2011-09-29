# add protection against updating locked fields
class Account < ActiveRecord::Base
  include InstanceCache
  include ActsAsProtected
  
  #acts_as_protected
  acts_as_tree :order => "name"
  
  has_and_belongs_to_many :groups, :uniq => true

  has_many :user_accounts, :dependent => :destroy
  belongs_to :user
  belongs_to :account_type
  has_many :users, :through => :user_accounts
  
  has_many :events_accounts, :foreign_key => "account_id"
  
  validates_presence_of :name, :user_id
  validates_length_of :name, :in => 3..40
  
  def initialize(*args)
    @read_only = false
    @cache = {}
    super(*args)
  end
  
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
  
  def Account.find_link_out(user)
    usrAcct = UserAccount.find(:first, :select => "*", :conditions => ["user_accounts.`user_id` = ? AND user_accounts.`isLink` = 1 AND accounts.`user_id` = ?", user.id, User.current_user.id], :include => :account)
    usrAcct ? usrAcct.account : nil
  end
  
  def Account.find_link_in(user)
    usrAcct = UserAccount.find(:first, :select => "*", :conditions => ["user_accounts.`user_id` = ? AND user_accounts.`isLink` = 1 AND accounts.`user_id` = ?", User.current_user.id, user.id], :include => :account)
    usrAcct ? usrAcct.account : nil
  end
  
  #def Account.find_by_sql(sql)
  #  filterRecords(super(sql))
  #end
  
  # TODO Abstract the filtering functionality into a library?
  #def Account.filterRecords(records)
  #  records.select { |record| self.allowed?(record) }
  #end
  
  # TODO Custom SQL to make authentication more efficient?
  def Account.allowed?(record)
    begin
    (record != nil) && 
      ((record.id == MASTER_ID) || 
      (User.current_user.instance_of?(User) && 
        ((User.current_user.id == record.user_id) || 
          (User.current_user.admin?) ||
          (User.current_user.view && record.read_only = true) ||
          (record.users.include?(User.current_user)))
        )
      )
    rescue
      raise $!
    end
  end
  
  def amount(time = nil)
    debit = 0
    credit = 0
    
    self.debits.each do |eventAcct|
      if time == nil || eventAcct.event.moment <= time 
        debit = debit + eventAcct.amount  
      end
    end 
     self.credits.each do |eventAcct|
      if time == nil || eventAcct.event.moment <= time 
        credit = credit + eventAcct.amount
      end
    end
    
    multiplier =  self.asset? ? 1 : -1
    
    amt = debit*multiplier - credit*multiplier
    
    self.children.each do |child|
      amt = amt + child.amount(time)
    end
    amt
  end
  
  def deleteLock?
    self.deleteLock == 1
  end
  
  def parentLock?
    self.parentLock == 1
  end
  
  def asset?
    self.account_type_id == ASSET_ACCT ||self.ancestors.include?(Account.find(:first, :conditions => ['account_type_id = ? AND user_id = ?', ASSET_ACCT, self.user_id]))
  end
  
  def link?
    user_accounts.each do |userAcct|
      if(userAcct.isLink == 1)
        return true
      end
    end
    return false
  end
  
  def toplevel?
    self.id == MASTER_ID
  end
  
  def destroy
    return unless !deleteLock?
    self.groups.clear
    
    self.debits.each do |deb|
      deb.update_attribute(:account_id, self.parent.id)
    end
    self.credits.each do |cred|
      cred.update_attribute(:account_id, self.parent.id)  
    end
    super
  end
  
  def destroy!
    self.deleteLock = 0
    self.destroy
  end
  
  def setAuthorized(param)
    return unless param != nil
    param.each do |username|
      user = User.find_by_name(username);
      userAcct = UserAccount.new( { :user_id => user.id, :account_id => self.id, :permissions => 1, :isLink => 0 })
      if userAcct.save
        addLinkers(user)
      else
        #userAcct.errors.full_messages << "<br />"
      end
    end 
  end
  
  def read_only?
    return @read_only
  end

  # TODO protect this?
  def read_only=(val)
    @read_only = val && true
  end
  
  private
  
  def addLinkers(user)    
    current_user = User.current_user
    if Account.find_link_out(user) == nil
      acct = Account.new( { :name => user.name, :user_id => current_user.id, :account_type_id => LINK_ACCT, :parent_id => Account.find(:first, :conditions => { :account_type_id => ASSET_ACCT, :user_id => current_user.id}).id, :deleteLock => 1, :parentLock => 0 })
      acct.save
      UserAccount.create( { :user_id => user.id, :account_id => acct.id, :permissions => 1, :isLink => 1 })
    end
    if Account.find_link_in(user) == nil
      User.current_user = user
      begin
        acct = Account.create( { :name => current_user.name, :user_id => user.id, :account_type_id => LINK_ACCT, :parent_id => Account.find(:first, :conditions => { :account_type_id => ASSET_ACCT, :user_id => user.id}).id, :deleteLock => 1, :parentLock => 0 })
        UserAccount.create( { :user_id => current_user.id, :account_id => acct.id, :permissions => 1, :isLink => 1 })
      rescue
        raise $!
      ensure
        User.current_user = current_user
      end
    end
  end
 
  init_caches [:amount, :credits, :debits, 'asset?', 'link?']
end

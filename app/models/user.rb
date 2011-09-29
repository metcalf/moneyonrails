require 'digest/sha1'
class User < ActiveRecord::Base
  
  #acts_as_access_group
  
  has_many :accounts, :through => :user_accounts, :dependent => :destroy
  has_many :user_accounts
  has_many :events, :dependent => :destroy
  has_many :alerts, :dependent => :destroy
  has_many :groups
  
  # Virtual attribute for the unencrypted password
  attr_accessor :password
  # Virtual attribute for view
  attr_accessor :view
  
  cattr_accessor :current_user
  
  validates_presence_of     :login, :email, :name
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..40
  validates_length_of       :email,    :within => 3..100
  validates_length_of       :name,    :within => 3..100
  validates_uniqueness_of   :login, :email, :case_sensitive => false
  
  before_create :make_activation_code
  before_save :encrypt_password
  
  def initialize(*args)
    @view = false
    super(*args)
  end
  
  def save(*args)
    # TODO simplify this... prevent saving
    new = self.new_record?
    ret = super(*args)
    if new
      root = Account.new(:user_id => self.id, :parent_id => MASTER_ID, :name => 'root', :deleteLock => 1, :parentLock => 1, :account_type_id => ROOT_ACCT)
      ret = ret && root.save
      self.errors.add_to_base(root.errors.full_messages)
      
      assets = Account.new(:user_id => self.id, :parent_id => root.id, :name => 'Assets', :account_type_id => ASSET_ACCT, :deleteLock => 1, :parentLock => 1)
      ret = ret && assets.save
      self.errors.add_to_base(assets.errors.full_messages)
      
      liabilities = Account.new(:user_id => self.id, :parent_id => root.id, :name => 'Liabilities', :deleteLock => 1, :account_type_id => LIABILITY_ACCT, :parentLock => 1)
      ret = ret && liabilities.save
      self.errors.add_to_base(liabilities.errors.full_messages)
      
      equity = Account.new(:user_id => self.id, :parent_id => root.id, :name => 'Shareholder\'s Equity', :account_type_id => EQUITY_ACCT, :deleteLock => 1, :parentLock => 1)
      ret = ret && equity.save
      self.errors.add_to_base(equity.errors.full_messages)
    end
    
    ret 
  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find :first, :conditions => ['login = ? and activated_at IS NOT NULL', login] 
    u && u.authenticated?(password) ? u : nil
  end
  
  # Activates the user in the database.
  def activate
    @activated = true
    update_attributes(:activated_at => Time.now.utc, :activation_code => nil)
  end

  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end
  
  def admin?
    self.level == 9
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    self.remember_token_expires_at = 2.weeks.from_now.utc
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  protected
    # before save filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end
    
    def password_required?
      crypted_password.blank? || !password.blank?
    end
    
    # before create filter
    def make_activation_code
      self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    end
    
end
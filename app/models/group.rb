class Group < ActiveRecord::Base
  has_and_belongs_to_many :accounts
  belongs_to :user
  
  def self.getRoot(user = User.current_user)
    RootGroup.new(user.groups)
  end
  
  def children
    self.accounts
  end
  
  def parent
    self.getRoot(self.user)
  end
  
  def destroy
    if(User.current_user != nil && (User.current_user = self.user || User.current_user.admin?))
      self.accounts.clear
      super
    end
  end
end

class RootGroup
  def initialize(groups)
    @groups = groups
  end
  
  def name
    "root"
  end
  
  def children
    @groups
  end
  
  def parent
    nil
  end
end
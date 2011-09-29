class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table "accounts" do |t|
      t.column "name",            :string,  :limit => 100, :null => false
      t.column "user_id",         :integer,                :null => false
      t.column "parent_id",       :integer               
      t.column "deleteLock",      :integer, :limit => 1
      t.column "parentLock",      :integer, :limit => 1
      t.column "account_type_id", :integer,                :null => false
    end
    
    Account.create(:id => 1, :name => 'master', :user_id => 0, :account_type_id => 0)
  end

  def self.down
    drop_table :accounts
  end
end

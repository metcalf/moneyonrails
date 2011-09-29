class CreateUserAccounts < ActiveRecord::Migration
  def self.up
    create_table "user_accounts" do |t|
      t.column "user_id",     :integer,              :null => false
      t.column "account_id",  :integer,              :null => false
      t.column "permissions", :integer, :limit => 1
      t.column "isLink",      :integer, :limit => 1
    end
  end

  def self.down
    drop_table :user_accounts
  end
end

class CreateUsersGroups < ActiveRecord::Migration
  def self.up
    create_table "accounts_groups", :id => false do |t|
      t.column "account_id",  :integer, :null => false
      t.column "group_id", :integer, :null => false
    end
  end

  def self.down
    drop_table :users_groups
  end
end

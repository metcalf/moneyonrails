class CreateEventsAccounts < ActiveRecord::Migration
  def self.up
    create_table "events_accounts" do |t|
      t.column "amount",     :decimal,              :precision => 12, :scale => 2, :null => false
      t.column "event_id",   :integer,                                             :null => false
      t.column "account_id", :integer,                                             :null => false
      t.column "is_credit",  :integer, :limit => 1,                                :null => false
    end
  end

  def self.down
    drop_table :events_accounts
  end
end

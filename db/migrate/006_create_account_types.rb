class CreateAccountTypes < ActiveRecord::Migration
  def self.up
    create_table "account_types" do |t|
      t.column "name", :string, :limit => 100, :null => false
    end
    AccountType.create(:id => 1, :name => "Asset")
    AccountType.create(:id => 2, :name => "Liability")
    AccountType.create(:id => 3, :name => "Shareholder's Equity")
    AccountType.create(:id => 4, :name => "User Link")
    AccountType.create(:id => 5, :name => "Normal")
    AccountType.create(:id => 6, :name => "Root")
  end

  def self.down
    drop_table :account_types
  end
end

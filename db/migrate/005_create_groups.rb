class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table "groups" do |t|
      t.column "name", :string, :limit => 100, :null => false
      t.column "user_id", :integer, :limit => 11, :null => false
    end
  end

  def self.down
    drop_table :groups
  end
end

class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table "events" do |t|
      t.column "user_id", :integer,                :null => false
      t.column "name",    :string,  :limit => 150, :null => false
      t.column "moment",  :date,                   :null => false
      t.column "isEstimate", :integer, :limit => 1
    end
  end

  def self.down
    drop_table :events
  end
end

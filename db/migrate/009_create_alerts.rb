class CreateAlerts < ActiveRecord::Migration
  def self.up
    create_table :alerts do |t|
      t.column :alert_type_id, :integer, :limit => 11
      t.column :user_id,       :integer, :limit => 11
      t.column :email,         :string,  :limit => 250
    end
  end

  def self.down
    drop_table :alerts
  end
end

class CreateAlertParameters < ActiveRecord::Migration
  def self.up
    create_table :alert_parameters do |t|
      t.column :alert_id,                 :integer, :limit => 11
      t.column :value,                    :string, :limit => 100
      t.column :alert_parameter_type_id,  :integer, :limit => 11
    end
  end

  def self.down
    drop_table :alert_parameters
  end
end

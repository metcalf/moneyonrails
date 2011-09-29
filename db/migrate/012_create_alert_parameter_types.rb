class CreateAlertParameterTypes < ActiveRecord::Migration
  def self.up
    create_table :alert_parameter_types do |t|
      t.column :name, :string, :limit => 100
    end
    AlertParameterType.create(:name => "amount")
    AlertParameterType.create(:name => "account_id")
    AlertParameterType.create(:name => "")
    
    
  end

  def self.down
    drop_table :alert_parameter_types
  end
end

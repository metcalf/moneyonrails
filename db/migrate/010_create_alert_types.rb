class CreateAlertTypes < ActiveRecord::Migration
  def self.up
    create_table :alert_types do |t|
      t.column :subject,  :string, :limit => 100
      t.column :body,     :string, :limit => 1000
      t.column :function, :string, :limit => 50
    end
    AlertType.create(:subject => "", :body => "", :function => "Greater")
    AlertType.create(:subject => "", :body => "", :function => "Less")
    AlertType.create(:subject => "", :body => "", :function => "Changed")
    
  end

  def self.down
    drop_table :alert_types
  end
end

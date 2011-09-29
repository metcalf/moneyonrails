class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table "users" do |t|
      t.column :name,             :string,    :limit => 100
      t.column :email,            :string,    :limit => 100
      t.column :login,            :string,    :limit => 50
      t.column :crypted_password, :string,    :limit => 40
      t.column :created_at,       :datetime
      t.column :updated_at,       :datetime
      t.column :activated_at,     :datetime
      t.column :activation_code,  :string,    :limit => 40
      t.column :salt,             :string,    :limit => 40
      t.column :level,            :integer,   :limit => 1
    end
  end

  def self.down
    drop_table :events
  end
end
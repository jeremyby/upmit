class AddTimezoneToUsers < ActiveRecord::Migration
  def change
    add_column :users, :timezone, :string
    
    remove_column :goals, :timezone, :string
  end
end

class AddGetEncourageToUsers < ActiveRecord::Migration
  def change
    add_column :users, :get_encourage, :boolean
  end
end

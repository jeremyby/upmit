class AddCheckinWithToUsers < ActiveRecord::Migration
  def change
    add_column :users, :checkin_with, :string
  end
end

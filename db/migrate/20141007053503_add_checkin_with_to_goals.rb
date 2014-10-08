class AddCheckinWithToGoals < ActiveRecord::Migration
  def change
    add_column :goals, :checkin_with, :string
  end
end

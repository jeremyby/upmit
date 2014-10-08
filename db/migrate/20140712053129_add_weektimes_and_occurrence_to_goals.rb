class AddWeektimesAndOccurrenceToGoals < ActiveRecord::Migration
  def change
    add_column :goals, :weektimes, :integer
    add_column :goals, :duration, :integer, null: false
    add_column :goals, :occurrence, :integer
  end
end

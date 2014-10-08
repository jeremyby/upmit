class AddStartsToGoals < ActiveRecord::Migration
  def change
    add_column :goals, :starts, :integer, default: 1 
  end
end

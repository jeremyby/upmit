class AddLegendToGoal < ActiveRecord::Migration
  def change
    add_column :goals, :legend, :string
  end
end

class AddDurationDescToGoals < ActiveRecord::Migration
  def change
    add_column :goals, :duration_desc, :string
  end
end

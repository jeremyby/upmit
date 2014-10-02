class AddHashTagToGoals < ActiveRecord::Migration
  def change
    add_column :goals, :hash_tag, :string, index: true
  end
end

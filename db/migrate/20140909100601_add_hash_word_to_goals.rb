class AddHashWordToGoals < ActiveRecord::Migration
  def change
    add_column :goals, :hash_word, :string
  end
end

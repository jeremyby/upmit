class AddPrivacyToGoals < ActiveRecord::Migration
  def change
    add_column :goals, :privacy, :integer, default: 10
  end
end

class CreateGoalActivities < ActiveRecord::Migration
  def change
    create_table :goal_activities do |t|
      t.string :activeable_type
      t.integer :activeable_id
      t.integer :goal_id

      t.timestamps
    end
  end
end

class GoalActivities < ActiveRecord::Base
  belongs_to :goal
  
  belongs_to :activeable, :polymorphic => true
end

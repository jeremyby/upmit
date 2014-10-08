class Reminder < ActiveRecord::Base
  belongs_to :user
  
  States = {
    1   => 'active',
    0   => 'inactive'
  }
  
  acts_as_stateable states: States
end

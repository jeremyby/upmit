class Reminder < ActiveRecord::Base
  belongs_to :user
  
  STATES = {
    1   => 'active',
    0   => 'inactive'
  }
  
end

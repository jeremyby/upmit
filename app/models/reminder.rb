class Reminder < ActiveRecord::Base
  belongs_to :user
  
  STATES = {
    1   => 'active',
    0   => 'inactive'
  }
  
  def remind(user)
    goals = Goal.remindable_for(user)
    
    items = []
    
    goals.each do |g|
      items << [g.title, g.hash_word]
    end
    
    self.deliver(items.uniq)
  end
end

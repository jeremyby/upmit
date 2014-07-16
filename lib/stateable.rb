module Stateable
  def acts_as_stateable(options)
    options[:states].each do |state|
      define_method("#{state[1]}?") do
        self.state == state[0]
      end

      define_method("#{state[1]}!") do
        self.update_attribute(:state, state[0])
      end
    end
    
    include InstanceMethods
  end
  
  module InstanceMethods
    def state_in_words
      self.class::STATES[self.state]
    end
  end
end

ActiveRecord::Base.extend Stateable
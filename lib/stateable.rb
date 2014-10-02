module Stateable
  def acts_as_stateable(options)
    options[:states].each do |state|
      scope state[1], -> { where(state: state[0]) }
      
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
      self.class::States[self.state]
    end
  end
end

ActiveRecord::Base.extend Stateable
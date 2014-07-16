# Load the Rails application.
require File.expand_path('../application', __FILE__)

if "irb" == $0
  ActiveRecord::Base.logger = Logger.new(STDOUT)
  ActiveSupport::Cache::Store.logger = Logger.new(STDOUT)
end

# Initialize the Rails application.
Rails.application.initialize!

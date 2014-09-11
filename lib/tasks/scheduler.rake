desc "This task is called by the Heroku scheduler add-on"
task :fail_expired_commits => :environment do
  puts "Failing commits that are active and late..."
  
  now  = Time.now.utc
  
  if Rails.env.development?
    failed = Commit.expired_commitments
    size = failed.size
    
    failed.each {|f| f.update_attribute(:state, rand(100) > 80 ? -1 : 1) }
    
    puts "#{ size } commits were failed."
  else
    Commit.expired_commitments.update_all("state = -1")
    puts "and... done."
  end
end

task :remind_active_commits => :environment do
  puts "Sending reminders for users..."

  User.remindables.find_each do |u|
    u.reminders.each do |r|
      r.remind(u)
      
      puts "Sending #{r.type} for User #{u.id}."
    end
  end
end



namespace :commits do
  desc "This task is called by the Heroku scheduler add-on"
  task :expire => :environment do
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

  task :remind => :environment do
    puts "Sending reminders for users..."


    User.remindables.find_each do |u|

      now = Time.now.in_time_zone(u.timezone)
      day_start = now.beginning_of_day
      week_start = now.beginning_of_week(start_day = :sunday)

      goals = u.goals.joins(:commits)
      .where("commits.state = 0")
      .where("(goals.type <> 'WeektimeGoal' AND commits.starts_at = ? AND commits.reminded < 0)
            OR (goals.type = 'WeektimeGoal' AND commits.starts_at = ? AND commits.reminded < ?)",
             day_start,
             week_start,
             now.wday)
      .select('DISTINCT goals.*')
      
      # goals can be blank for User.remindables picks all users with weektime goals
      unless goals.blank?
        items = goals.collect {|g| [g.title, g.hash_tag]}
      
        u.reminders.each do |r|
          r.deliver(items)
      
          puts "Sending #{r.type} for User #{u.id}. Message: #{ items.to_s }"
        end
      
        goals.each do |g|
          if g.is_a?(WeektimeGoal)      
            commits = g.commits.active.where(starts_at: week_start).where("reminded < ?", now.wday)
      
            commits.update_all(reminded: now.wday)
          else
            commits = g.commits.active.where(starts_at: day_start).where("reminded < 0")
          
            commits.update_all(reminded: 0)
          end
        end
      end
    end
  end
end

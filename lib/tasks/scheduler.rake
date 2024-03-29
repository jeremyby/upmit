
namespace :commits do
  task :expire => :environment do
    puts "Failing commits that are active and late..."

    now  = Time.now.utc

    if Rails.env.development?
      failed = Commit.expired_commitments
      size = failed.size

      failed.each {|f| f.update state: rand(100) > 80 ? -10 : 1, checked_by: 'host', checked_at: Time.now }

      puts "#{ size } commits were expired."
    else
      Commit.expired_commitments.find_each do |c|
        c.update state: -10, checked_by: 'upbot', checked_at: Time.now
      end
      
      puts "and... done."
    end
  end

  task :remind => :environment do
    puts "Sending reminders for users..."

    User.remindables.find_each do |u|
      now = Time.now

      goals = u.goals.active.joins(:commits)
                            .where("commits.state = 0")
                            .where("commits.starts_at < ?", now)
                            .where("(goals.type <> 'WeektimeGoal' AND commits.reminded < 0)
                                    OR (goals.type = 'WeektimeGoal' AND commits.reminded < ?)",
                                   now.in_time_zone(u.timezone).wday)
                            .select('DISTINCT goals.*')

      # goals can be blank for User.remindables picks all users with weektime goals
      unless goals.blank?
        items = goals.collect {|g| [g.title, g.hash_tag]}

        u.reminders.each do |r|
          if r.active?
            puts "Sending #{ r.type } for User #{ u.id }. Message: #{ items.to_s }" if r.deliver(items)
          end
        end

        goals.each do |g|
          if g.is_a?(WeektimeGoal)
            g.commits.active.where("commits.starts_at < ?", now)
                            .where("reminded < ?", now.in_time_zone(u.timezone).wday)
                            .update_all(reminded: now.in_time_zone(u.timezone).wday)
          else
            g.commits.active.where("commits.starts_at < ?", now)
                            .where("reminded < 0")
                            .update_all(reminded: 0)
          end
        end
      end
    end
  end
end


namespace :check do
  task  :twitter => :environment do
    puts "Retrieve @upmit tweets to check users in..."

    begin
      tweets = UpmitTwitter.mentions(since_id: UpmitMentionSince.twitter, count: 200)
    rescue Twitter::Error::TooManyRequests => error
      # NOTE: Your process could go to sleep for up to 15 minutes but if you
      # retry any sooner, it will almost certainly fail with the same exception.
      sleep error.rate_limit.reset_in + 1
      retry
    end

    puts "Processing #{ tweets.size } tweets"

    unless tweets.blank? # Having new mentions
      tweets.each do |t|
        puts "Tweet: #{ t.text }"

        auth = Authorization.find_by(uid: t.user.id, provider: 'twitter') # Find user with the Twitter uid

        unless auth.blank? # No such user
          now = Time.now

          unless t.hashtags.blank?
            hash_array = t.hashtags.collect {|h| h.text}

            commits = auth.user.commits.active.joins(:goal)
                                        .where("goals.checkin_with = 'twitter'")
                                        .where("goals.state = 10")
                                        .where("goals.hash_tag in (?)", hash_array)
                                        .where("commits.starts_at < ?", now)
                                        .group('commits.goal_id')

            # pp commits

            unless commits.blank?
              Commit.transaction do
                commits.each do |c|
                  c.update state: 1, note: t.text, checked_by: 'twitter', checked_at: t.created_at, remote_photo_url: t.media.first.present? ? t.media.first.media_url.to_s : nil
                end
              end
            end
          end
        end

        UpmitMentionSince.update_attribute(:twitter, tweets.first.id)
      end
    end
  end
  
  task  :facebook => :environment do
    puts "Checking posts Facebook users tagged the page @upmit"
    
    
    graph = Koala::Facebook::API.new(Facebook_user_access_token)
    
    results = []
    
    posts = graph.get_connections(Facebook_page_id, 'tagged')
    
    results += posts
    
    first_id = posts.first['id'].split('_').last.to_i
    last_id = posts.last['id'].split('_').last.to_i
    
    # retrive all new posts
    while last_id > UpmitMentionSince.facebook do
      posts = posts.next_page
      
      results += posts
      
      last_id = posts.last['id'].split('_').last.to_i
    end
    
    results.delete_if {|r| r['id'].split('_').last.to_i <= UpmitMentionSince.facebook }
    
    puts "#{ results.size } new posts need to check."
    
    unless results.blank?
      results.each do |r|
        auth = Authorization.find_by(uid: r['from']['id'], provider: 'facebook') # Find user with the Facebook uid
        
        unless auth.blank? # No such user
          messages = r['message'].split
          
          messages.delete_if {|m| m[0] != '#' }
          
          unless messages.blank?
            now = Time.now
            
            messages.each {|m| m[0] = ''}
            
            commits = auth.user.commits.active.joins(:goal)
                                        .where("goals.checkin_with = 'facebook'")
                                        .where("goals.state = 10")
                                        .where("goals.hash_tag in (?)", messages)
                                        .where("commits.starts_at < ?", now)
                                        .group('commits.goal_id')
            
            #pp commits
            
            unless commits.blank?
              Commit.transaction do
                commits.each do |c|
                  c.update state: 1, note: r['message'], checked_by: 'facebook', checked_at: Time.parse(r['created_time']), remote_photo_url: r['picture']
                end
              end
            end
          end
        end
      end
    end
    
    UpmitMentionSince.update_attribute(:facebook, first_id)
  end
end

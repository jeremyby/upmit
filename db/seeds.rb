# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


# %w(User Goal Commit Deposit Reminder).each do |model|
#   model.constantize.destroy_all
# end


# User.create! display_name: 'Jeremy Yang', email: 'jeremyby@gmail.com', password: '19781115', password_confirmation: '19781115', timezone: 'Asia/Shanghai'
# User.create! display_name: 'Bin Yang', email: 'b.yang@live.com', password: '19781115', password_confirmation: '19781115', timezone: 'America/New_York'
# User.create! display_name: 'Jeremy Yang', email: 'jeremyyang@gmail.com', password: '19781115', password_confirmation: '19781115', timezone: 'Asia/Shanghai', confirmed_at: Time.now
# 
# User.first.confirm!

def create_goal(goal, schedule)
  goal.occurrence = schedule.all_occurrences.size * (goal.weektimes.blank? ? 1 : goal.weektimes)
  goal.schedule_yaml = schedule.to_yaml
  goal.timezone = 'Asia/Shanghai'
  goal.save

  if goal.active?
    # since the goal was created with the active state,
    # creating deposit will not trigger goal.active! hence creating all commits
    goal.create_deposit(user_id: 1, token: 'abcd', payer: 'abcd', amount: Money.new(goal.occurrence * 100), source: 'paypal')

    weektimes = goal.weektimes.blank? ? 1 : goal.weektimes
    weektimes.times do
      goal.schedule.all_occurrences.each do |o|
        goal.commits.create({state: 0, starts_at: o, user: User.first})
      end
    end
  end
end

# 1st goal of first user, daily
g = User.first.goals.build title: 'make real progress at work', state: 10, duration: 100, interval_unit: 'day', type: 'DailyGoal', hash_tag: 'MakeProgress'

start_time = (Time.now.in_time_zone('Asia/Shanghai') - 110.days).beginning_of_day
schedule = IceCube::Schedule.new(start_time)
end_time = start_time + (g.duration - 1).days

schedule.add_recurrence_rule IceCube::Rule.daily.until(end_time)

g.start_time = start_time
create_goal(g, schedule)
g.deposit.completed!


# 2nd goal of first user, weekdays
g = User.first.goals.build title: 'run for 10 minutes', state: 10, duration: 184, interval_unit: 'week', weekdays: [1, 3, 5], type: 'WeekdayGoal', hash_tag: 'running', checkin_with: 'facebook'

start_date = Time.now.in_time_zone('Asia/Shanghai') - 82.days
start_time = (start_date - start_date.wday.days).beginning_of_day
schedule = IceCube::Schedule.new(start_time)
end_time = start_time + (g.duration - 1).days

schedule.add_recurrence_rule IceCube::Rule.weekly.day(g.weekdays).until(end_time)

g.start_time = start_time
create_goal(g, schedule)


# 3rd goal of first user, twice a week
g = User.first.goals.build title: 'shopping', state: 10, duration: 365, interval_unit: 'week', weektimes: 2, type: 'WeektimeGoal', hash_tag: 'shopping', checkin_with: 'twitter'

start_date = Time.now.in_time_zone('Asia/Shanghai') - 24.days
start_time = (start_date - start_date.wday.days).beginning_of_day
schedule = IceCube::Schedule.new(start_time)
end_time = start_time + (g.duration - 1).days

schedule.add_recurrence_rule IceCube::Rule.weekly.until(end_time)

g.start_time = start_time
create_goal(g, schedule)


# 4th goal of first user, same title of the 1st one
g = User.first.goals.build title: 'make real progress at work', state: 10, duration: 365, interval_unit: 'day', type: 'DailyGoal', hash_tag: 'ProgressAtWork', checkin_with: 'twitter'

start_time = (Time.now.in_time_zone('Asia/Shanghai') - 56.days).beginning_of_day
schedule = IceCube::Schedule.new(start_time)
end_time = start_time + (g.duration - 1).days

schedule.add_recurrence_rule IceCube::Rule.daily.until(end_time)

g.start_time = start_time
create_goal(g, schedule)


# 5th goal of first user, new goal
g = User.first.goals.build title: 'not smoke', duration: 100, interval_unit: 'day', type: 'DailyGoal', hash_tag: 'NoSmoking', checkin_with: 'twitter'

start_time = Time.now.in_time_zone('Asia/Shanghai').beginning_of_day
schedule = IceCube::Schedule.new(start_time)
end_time = start_time + (g.duration - 1).days

schedule.add_recurrence_rule IceCube::Rule.daily.until(end_time)

g.start_time = start_time
create_goal(g, schedule)


# 6th goal of first user, finished today
g = User.first.goals.build title: 'do something useful', state: 10, duration: 100, interval_unit: 'day', type: 'DailyGoal', hash_tag: 'do', checkin_with: 'twitter'

start_time = (Time.now.in_time_zone('Asia/Shanghai') - 99.days).beginning_of_day
schedule = IceCube::Schedule.new(start_time)
end_time = start_time + (g.duration - 1).days

schedule.add_recurrence_rule IceCube::Rule.daily.until(end_time)

g.start_time = start_time
create_goal(g, schedule)
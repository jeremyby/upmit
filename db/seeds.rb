# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.create([
  {first_name: 'Jeremy', last_name: 'Yang', email: 'jeremyby@gmail.com', password: '19781115', password_confirmation: '19781115'},
  {first_name: 'Bin', last_name: 'Yang', email: 'b.yang@live.com', password: '19781115', password_confirmation: '19781115'},
  {first_name: 'Jeremy', last_name: 'Yang', email: 'jeremyyang@gmail.com', password: '19781115', password_confirmation: '19781115'}
])

# first goal of first user, daily
g = User.first.goals.build({title: 'make real progress at work', timezone: 'America/Los_Angeles', state: 10, duration: 100})

g.start_time = (Time.now.in_time_zone(g.timezone) - 24.days).beginning_of_day
schedule = IceCube::Schedule.new(g.start_time)
end_time = g.start_time + (g.duration - 1).days

schedule.add_recurrence_rule IceCube::Rule.daily.until(end_time)

g.occurrence = schedule.all_occurrences.size
g.schedule_yaml = schedule.to_yaml
g.save

g.schedule.occurrences(Time.now.in_time_zone(g.timezone)).each {|o| g.commits.create({state: rand(100) > 80 ? -1 : 1, starts_at: o})}

# 2nd goal of first user, weekdays
g = User.first.goals.build({title: 'run for 60 minutes', timezone: 'Asia/Shanghai', state: 10, duration: 184})
start_date = Time.now.in_time_zone(g.timezone) - 82.days
g.start_time = start_date.change(day: start_date.day - start_date.wday).beginning_of_day
schedule = IceCube::Schedule.new(g.start_time)
end_time = g.start_time + (g.duration - 1).days

schedule.add_recurrence_rule IceCube::Rule.weekly.day([1, 3, 5]).until(end_time)

g.occurrence = schedule.all_occurrences.size
g.schedule_yaml = schedule.to_yaml
g.save

g.schedule.occurrences(Time.now.in_time_zone(g.timezone)).each {|o| g.commits.create({state: rand(100) > 80 ? -1 : 1, starts_at: o})}

# 3rd goal of first user, twice a week
g = User.first.goals.build({title: 'shopping', timezone: 'Europe/London', state: 10, duration: 365})
start_date = Time.now.in_time_zone(g.timezone) - 24.days
g.start_time = start_date.change(day: start_date.day - start_date.wday).beginning_of_day
schedule = IceCube::Schedule.new(g.start_time)
end_time = g.start_time + (g.duration - 1).days

schedule.add_recurrence_rule IceCube::Rule.weekly.until(end_time)

g.weektimes = 2
g.occurrence = schedule.all_occurrences.size
g.schedule_yaml = schedule.to_yaml
g.save

g.schedule.occurrences(Time.now.in_time_zone(g.timezone)).each {|o| g.commits.create({state: rand(100) > 90 ? -1 : 1, starts_at: o})}


# 4th goal of first user, same title of the 1st one
g = User.first.goals.build({title: 'make real progress at work', timezone: 'Europe/London', state: 10, duration: 365})

g.start_time = (Time.now.in_time_zone(g.timezone) - 56.days).beginning_of_day
schedule = IceCube::Schedule.new(g.start_time)
end_time = g.start_time + (g.duration - 1).days

schedule.add_recurrence_rule IceCube::Rule.daily.until(end_time)

g.occurrence = schedule.all_occurrences.size
g.schedule_yaml = schedule.to_yaml
g.save

g.schedule.occurrences(Time.now.in_time_zone(g.timezone)).each {|o| g.commits.create({state: rand(100) > 90 ? -1 : 1, starts_at: o})}

# first goal of second user, new goal
g = User.last.goals.build({title: 'not smoke', timezone: 'America/Los_Angeles', state: 10, duration: 100})

g.start_time = Time.now.in_time_zone(g.timezone).beginning_of_day
schedule = IceCube::Schedule.new(g.start_time)
end_time = g.start_time + (g.duration - 1).days

schedule.add_recurrence_rule IceCube::Rule.daily.until(end_time)

g.occurrence = schedule.all_occurrences.size
g.schedule_yaml = schedule.to_yaml
g.save
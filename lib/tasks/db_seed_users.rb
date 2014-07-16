# encoding: UTF-8
namespace :db do
  namespace :seed do
    desc "Load user seed data for developement and test"
    task :users => :environment do
      users = [
        {:first_name => 'Eric', :last_name => 'Smith', :email  => 'smith@live.com', :password => '19781115', :password_confirmation  => '19781115'},
        {:first_name => 'Jeremy', :last_name => 'Yang', :email  => 'jeremyby@gmail.com', :password => '19781115', :password_confirmation  => '19781115'}
      ]

      # 200.times do |i|
      #   users << {:first_name => "user#{i+1}", :email  => "user#{i+1}@abc.com", :country_code => countries[rand(5)], :password => '111111', :password_confirmation  => '111111'}
      # end

      User.create(users)
    end
  end
end
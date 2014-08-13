source 'http://rubygems.org'
# source 'http://ruby.taobao.org/'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails'

gem 'haml'
gem 'haml-rails'

gem 'pg'

# Use SCSS for stylesheets
gem 'sass-rails'
gem 'compass-rails'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer',  platforms: :ruby

gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
gem 'jquery-turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'

# bundle exec rake doc:rails generates the API under doc/api.
# gem 'sdoc', '~> 0.4.0',          group: :doc

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
# gem 'spring',        group: :development

gem 'puma'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]


gem 'devise'
gem 'omniauth'

gem 'paypal-sdk-merchant', git: 'https://github.com/paypal/merchant-sdk-ruby.git'

gem 'friendly_id'
gem 'stringex'

gem 'ice_cube'

gem 'delayed_job_active_record'


group :development, :test do
  gem 'guard-rspec',      :require => false
  gem 'guard-livereload', :require => false
  gem 'rack-livereload'
  gem 'rb-fsevent',       :require => false
  
  gem 'quiet_assets'
end

group :production do
  gem 'rails_12factor'
end
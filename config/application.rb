require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Upmit
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'UTC'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
     
    
    config.assets.paths += ["#{Rails.root}/app/assets/images/legend/"]
    
    # General Settings
    config.app_domain = 'upmit.com'

    # Email
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.perform_deliveries = true
    config.action_mailer.default_url_options = { host: config.app_domain }
    config.action_mailer.smtp_settings = {
      address: 'smtp.gmail.com', 
      port: '587',
      enable_starttls_auto: true,
      user_name: 'upcommit',
      password: 'Jackyby-1',
      authentication: :plain,
      domain: 'upmit.com'
    }
  end
end

# config valid only for Capistrano 3.1
lock '3.2.1'

set :application, 'upmit'
set :repo_url, 'git@github.com:jeremyby/upmit.git'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/var/www/upmit'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug


# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

set :rbenv_type, :user # or :system, depends on your rbenv setup
set :rbenv_ruby, '2.1.2'
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
# set :rbenv_map_bins, %w{rake gem bundle ruby}
set :rbenv_roles, :all # default value


set :puma_rackup, -> { File.join(current_path, 'config.ru') }
set :puma_state, "#{shared_path}/tmp/pids/puma.state"
set :puma_pid, "#{shared_path}/tmp/pids/puma.pid"
set :puma_bind, "unix://#{shared_path}/tmp/sockets/puma.sock"
set :puma_conf, "#{shared_path}/puma.rb"
set :puma_access_log, "#{shared_path}/log/puma_error.log"
set :puma_error_log, "#{shared_path}/log/puma_access.log"
set :puma_role, :app
set :puma_env, fetch(:rack_env, fetch(:rails_env, 'production'))
set :puma_threads, [0, 16]
set :puma_workers, 0
set :puma_init_active_record, true
set :puma_preload_app, true


namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      # execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end
end

namespace :rails do
  desc "Start a rails console, for now just with the primary server"
  task :c do
    on roles(:app), primary: true do |role|
      rails_env = fetch(:rails_env)
      execute_remote_command_with_input "#{bundle_cmd_with_rbenv} #{current_path}/script/rails console #{rails_env}"
    end
  end

  def execute_remote_command_with_input(command)
    host = 'cambridge'
    puts "opening a console on: #{host}...."
    cmd = "ssh #{host} -t 'cd #{deploy_to}/current && #{command}'"
    exec cmd
  end

  def bundle_cmd_with_rbenv
    if fetch(:rbenv_ruby)
      "RBENV_VERSION=#{fetch(:rbenv_ruby)} RBENV_ROOT=#{fetch(:rbenv_path)}  #{File.join(fetch(:rbenv_path), '/bin/rbenv')} exec bundle exec"
    else
      "ruby "
    end
  end
end

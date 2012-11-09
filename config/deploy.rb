require 'bundler/capistrano'
set :default_environment, { 'PATH' => "'/home/johnsonch/bin:/home/johnsonch/.gems/bin:/home/johnsonch/.gems/bin:/usr/lib/ruby/gems/1.8/bin/:/usr/local/bin:/usr/bin:/bin:/usr/bin/X11:/usr/games'"}
set :user, 'johnsonch'
set :application, 'photoblog.johnsonch.com'
set :applicationdir, "/home/johnsonch/photoblog.johnsonch.com"
set :deploy_to, applicationdir
set :repository, "."
set :local_repository, "file://."
set :use_sudo, false
set :scm, "git"
set :deploy_via, :copy

role :web, application
role :app, application
role :db,  application, :primary => true

# if you want to clean up old releases on each deploy uncomment this:
after "deploy:restart", "deploy:cleanup"

ssh_options[:paranoid] = false

# =============================================================================
# OVERRIDE TASKS
# =============================================================================
namespace :deploy do
  desc "Restart Passenger" 
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt" 
  end
  namespace :assets do
    task :precompile, :roles => :web, :except => { :no_release => true } do
      from = source.next_revision(current_revision)
      if capture("cd #{latest_release} && #{source.local.log(from)} vendor/assets/ app/assets/ | wc -l").to_i > 0
        run %Q{cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:precompile}
      else
        logger.info "Skipping asset pre-compilation because there were no asset changes"
      end
    end
  end
end
namespace :db do
  task :db_config, :except => { :no_release => true }, :role => :app do
    upload("config/database.yml","#{release_path}/config/database.yml")
  end
end
after "deploy:finalize_update", "db:db_config"



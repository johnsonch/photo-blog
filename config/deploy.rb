require 'bundler/capistrano'
set :default_environment, { 'PATH' => "'/home/johnsonch/bin:/home/johnsonch/.gems/bin:/home/johnsonch/.gems/bin:/usr/lib/ruby/gems/1.8/bin/:/usr/local/bin:/usr/bin:/bin:/usr/bin/X11:/usr/games'"}
####################################################
#
set :user, 'johnsonch'
set :application, 'photoblog.johnsonch.com'
set :applicationdir, "/home/johnsonch/photoblog.johnsonch.com"
set :repository, "git://github.com/johnsonch/photo-blog.git" 

# =============================================================================
# You shouldn't have to modify the rest of these
# =============================================================================

role :web, application
role :app, application
role :db,  application, :primary => true
set :branch, "capistrano"

set :use_sudo, false
set :scm, "git"
# saves space by only keeping last 3 when running cleanup
set :keep_releases, 3 

# issues svn export instead of checkout

#set :deploy_via, :copy
set :deploy_to, applicationdir
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



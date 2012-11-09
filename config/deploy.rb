require 'bundler/capistrano'
#set :user, 'johnsonch'
#set :domain, 'johnsonch.com'
#set :applicationdir, "photoblog.johnsonch.com"
 
#set :scm, 'git'
#set :repository,  "git://github.com/johnsonch/photo-blog.git"
#set :local_repository, 'file://.git'
#set :branch, 'capistrano'
#set :scm_verbose, true
 
# roles (servers)
#role :web, domain
#role :app, domain
#role :db,  domain, :primary => true
 
# deploy config
#set :deploy_to, applicationdir
#set :deploy_via, :copy
 
# additional settings
#default_run_options[:pty] = true  # Forgo errors when deploying from windows
#ssh_options[:keys] = %w(/home/user/.ssh/id_rsa)            # If you are using ssh_keysset :chmod755, "app config db lib public vendor script script/* public/disp*"
#set :use_sudo, false
 
# Passenger
#namespace :deploy do
  #task :start do ; end
  #task :stop do ; end
  #task :restart, :roles => :app, :except => { :no_release => true } do
    #run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  #end
#end
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
end
namespace :db do
  task :db_config, :except => { :no_release => true }, :role => :app do
    upload("config/database.yml","#{release_path}/config/database.yml")
  end
end
after "deploy:finalize_update", "db:db_config"



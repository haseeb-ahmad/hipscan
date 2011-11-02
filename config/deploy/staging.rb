##############################################################
## Settings
##############################################################
#
#default_run_options[:pty] = true
##ssh_options[:forward_agent] = true
#set :use_sudo, false
#set :scm_verbose, false
#set :rails_env, "staging"
#
##############################################################
## Servers
##############################################################


set :domain, 'staging.socialpda.com'
set :deploy_to, "/var/www/hipscan"
set :rails_env, "staging"
set :user, "spda"
#
#set :domain, "testdev.net"
#set :user, "deploy"
##############################################################
## Passenger
##############################################################
#
#namespace :deploy do
#  # regen css
#  desc 'After deploy tasks'
#  task :after_deploy, :roles => :app, :except => { :no_release => true } do
#    # run "cd #{current_path}/.. && chown -R deploy:deploy *"
#  end
#
#  # Restart passenger on deploy
#  desc "Restarting mod_rails with restart.txt"
#  task :restart, :roles => :app, :except => { :no_release => true } do
#    run "touch #{current_path}/tmp/restart.txt"
#  end
#
#  [:start, :stop].each do |t|
#    desc "#{t} task is a no-op with mod_rails"
#    task t, :roles => :app do ; end
#  end
#
#
#end
#
#

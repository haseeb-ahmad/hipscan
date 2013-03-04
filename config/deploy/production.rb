##############################################################
## Settings
##############################################################
#
#default_run_options[:pty] = true
##ssh_options[:forward_agent] = true
#set :use_sudo, true
#set :scm_verbose, false
#set :rails_env, "production"
#
#
##############################################################
## Servers
##############################################################
#
#set :domain, "hipscan.com"
#set :user, "root"
#set :password, "server.hipscan.com5D5DcV5xq"
#ssh_options[:port] = 22
#
#server domain, :app, :web
#role :db, domain, :primary => true
#
#
##############################################################
## Passenger
##############################################################
#
#namespace :deploy do
#  # regen css
#  desc 'After deploy tasks'
#  task :after_deploy, :roles => :app, :except => { :no_release => true } do
#    run "cd #{current_path}/.. && chown -R nobody:nogroup *"
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
##############################################################
## Bundler
##############################################################
#
#namespace :bundler do
#  task :create_symlink, :roles => :app do
#    shared_dir = File.join(shared_path, 'bundle')
#    release_dir = File.join(current_release, '.bundle')
#    run("mkdir -p #{shared_dir} && ln -s #{shared_dir} #{release_dir}")
#  end
#
#  task :bundle_new_release, :roles => :app do
#    bundler.create_symlink
#    #run "cd #{release_path} && bundle install --without development test"
#    puts 'cap bundler is broken -- run bundle install --without development test'
#    puts 'manually on server'
#  end
#
#  task :lock, :roles => :app do
#    run "cd #{current_release} && bundle lock;"
#  end
#
#  task :unlock, :roles => :app do
#    run "cd #{current_release} && bundle unlock;"
#  end
#end

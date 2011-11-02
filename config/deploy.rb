# Run this on the server!
#
# sudo bundle install --deployment
# Fixed deploy by removing Enterprise Ruby
# See /etc/environment -- changed paths there so regular Ruby is used rather than Enterprise Ruby

#require 'capistrano/ext/multistage'
require 'bundler/capistrano'


set :whenever_command, "bundle exec whenever"
require "whenever/capistrano"

#############################################################
# Application
#############################################################

set :application, "hipscan"
# set :deploy_to, "/rails/#{application}"
set :deploy_to, "/rails/live_hipscan"

set :keep_releases, 4
after "deploy:update", "deploy:cleanup"
after "deploy:update_code", "bundler:bundle_new_release"


#############################################################
# SCM
#############################################################
set :scm, :git

#i set :repository, "ssh://johnc@testdev.net:2222/git/hipscan"
set :repository, 'git@caplu.com:hipscan.git'
ssh_options[:forward_agent] = true
set :branch, "master"
set :deploy_via, :remote_cache
set :copy_cache, true
set :copy_exclude, [".git/*", "deploy.rb", "deploy/*"]
set :copy_compression, :gzip

#############################################################
# Settings
#############################################################

default_run_options[:pty] = true
#ssh_options[:forward_agent] = true
#set :use_sudo, true
set :scm_verbose, false
set :rails_env, "production"
# set :rails_env, "staging"


#############################################################
# Servers
#############################################################

set :domain, "hipscan.com"
# set :domain, 'staging.socialpda.com'
set :user, "deploy"
# set :user, "spda"
set :password, "!!dxni9e"

#ssh_options[:port] = 2222

server domain, :app, :web
role :db, domain, :primary => true


#############################################################
# Passenger
#############################################################

namespace :deploy do
  desc 'After deploy tasks'
  task :after_deploy, :roles => :app, :except => { :no_release => true } do
    #run "cd #{current_path}/.. && chown -R nobody:nogroup *"
  end

  # Restart passenger on deploy
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end

  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end


end


#############################################################
# Bundler
#############################################################

namespace :bundler do
  task :create_symlink, :roles => :app do
    shared_dir = File.join(shared_path, 'bundle')
    release_dir = File.join(current_release, '.bundle')
    run("mkdir -p #{shared_dir} && ln -s #{shared_dir} #{release_dir}")
  end

  task :bundle_new_release, :roles => :app do
    bundler.create_symlink
    #run "cd #{release_path} && bundle install --without development test"
    puts 'cap bundler is broken -- run bundle install --without development test'
    puts 'manually on server'
  end

  task :lock, :roles => :app do
    run "cd #{current_release} && bundle lock;"
  end

  task :unlock, :roles => :app do
    run "cd #{current_release} && bundle unlock;"
  end
end


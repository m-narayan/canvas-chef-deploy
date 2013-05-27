#
# Cookbook Name:: portal
# Recipe:: default
#

# https://launchpad.net/~brightbox/+archive/passenger-nginx
# https://launchpad.net/~brightbox/+archive/ppa

include_recipe "apt"
#include_recipe "canvas"
#include_recipe "cas-server"

apt_repository "Brightbox_ruby_ng" do
  uri "http://ppa.launchpad.net/brightbox/ruby-ng/ubuntu"
  distribution "precise"
  components ["main"]
  keyserver "keyserver.ubuntu.com"
  key "C3173AA6"
  notifies :run, resources(:execute => "apt-get update"), :immediately
end

#apt_repository "Brightbox NGINX" do
#  uri "http://ppa.launchpad.net/brightbox/passenger-nginx/ubuntu"
#  distribution "precise"
#  components ["main"]
#  keyserver "keyserver.ubuntu.com"
#  key "C3173AA6"
#  notifies :run, resources(:execute => "apt-get update"), :immediately
#end

%w( ruby1.9.3 zlib1g-dev libxml2-dev postgresql-client libpq-dev libxslt1-dev
 imagemagick libpq-dev nodejs libxmlsec1-dev libcurl4-gnutls-dev
 libxmlsec1 build-essential openjdk-7-jre git-core zip unzip
 libpq-dev nodejs passenger-common1.9.1 ruby-switch nginx-full ).each do |pkg|; package pkg; end

service "nginx" do
  action :nothing
  supports :status => true, :start => true, :stop => true, :restart => true
end

group node["portal"]["system_group"] do
  gid node["portal"]["system_gid"]
  members 'www-data'
end

user node["portal"]["system_user"]  do
  uid node["portal"]["system_uid"]
  gid node["portal"]["system_gid"]
  home node["portal"]["home_dir"]
  system true
  shell "/bin/bash"
  supports :manage_home => true
end

# Try to create databases required for portal
ENV['PORTAL_DB_GEN_LOCK'] = "#{node['portal']['home_dir']}/#{node['portal']['name']}/.DB_GEN_DONE"
ENV['SQL_DB_NAME'] = node["portal"]["sql_db_name"]

if node["portal"]["sql_db_create_db"] == true
  if ( node["portal"]["sql_db_driver"] == "postgresql" )
        and   !File.file?("#{node['portal']['home_dir']}/#{node['portal']['name']}/.DB_GEN_DONE")

    script "Create Postgres Databases" do
      interpreter "bash"
    	user "postgres"
    	cwd "/tmp"
      code <<-EOH
         /usr/bin/createdb $SQL_DB_NAME
      EOH
    end

    script "Create DB Lock File" do
      interpreter "bash"
    	user node["portal"]["system_user"] 
    	cwd "/tmp"
      code <<-EOH
        touch $portal_DB_GEN_LOCK
      EOH
    end

  end
end

# END Try to create databases required for portal

directory "#{node['portal']['home_dir']}/#{node['portal']['name']}" do
  owner node["portal"]["system_user"]
  group  node["portal"]["system_group"]
  mode 0755
  action :create
end

git "#{node['portal']['home_dir']}/#{node['portal']['name']}" do
  repository node["portal"]["git_repo"] 
  branch node["portal"]["git_branch"]
  action :sync
  depth 1
  user    node["portal"]["system_user"]
  group   node["portal"]["system_group"]
end

directory "#{node['portal']['home_dir']}/#{node['portal']['name']}/tmp" do
  user    node["portal"]["system_user"]
  group   node["portal"]["system_group"]
  action :create
  mode 0755
end

directory "#{node['portal']['home_dir']}/#{node['portal']['name']}/log" do
  owner node["portal"]["system_user"]
  group  node["portal"]["system_group"]
  mode 0755
  action :create
end

directory "#{node['portal']['home_dir']}/#{node['portal']['name']}/tmp/pids" do
  owner node["portal"]["system_user"]
  group  node["portal"]["system_group"]
  mode 0755
  action :create
  recursive true
end

gem_package "bundler" do
	gem_binary("/usr/bin/gem1.9.3")
	options("--no-rdoc --no-ri")
end

script "Lets get the required GEMS" do
	not_if do ::File.file?("#{node['portal']['home_dir']}/#{node['portal']['name']}/Gemfile.lock") end
	interpreter "bash"
	user "root"
	cwd "#{node['portal']['home_dir']}/#{node['portal']['name']}"
	code "bundle --path vendor/bundle --without=sqlite"
end

template "/etc/profile.d/portal-enviroment.sh" do
	source "portal-enviorment.sh.erb"
	owner "root"
	group "root"
	mode 0444
end

template "#{node['portal']['home_dir']}/#{node['portal']['name']}/config/database.yml" do
	source "database.yml.erb"
  owner node["portal"]["system_user"]
  group  node["portal"]["system_group"]
	mode 0644
end

template "#{node['portal']['home_dir']}/#{node['portal']['name']}/config/production.yml" do
	source "production.yml.erb"
  owner node["portal"]["system_user"]
  group  node["portal"]["system_group"]
	mode 0644
end

script "Compile Assets" do
	interpreter "bash"
	cwd "#{node['portal']['home_dir']}/smart"
	not_if do ::File.directory?("#{node['portal']['home_dir']}/#{node['portal']['name']}/public/assets") end
	code "bundle exec rake assets:precompile"
end
#
#script "Compress Assets" do
#	interpreter "bash"
#	cwd "#{node['portal']['home_dir']}/#{node['portal']['name']}"
#	code "bundle exec rake db:assets_precompile"
#end

# if there is no nginx.conf then copy the file
if  !File.file?("/etc/nginx/nginx.conf")
  template "/etc/nginx/nginx.conf" do
    source "nginx.conf.erb"
    owner "root"
    group "root"
    mode 0444
  end
end

script "Remove old Nginx factory config" do
  only_if do ::File.symlink?( "/etc/nginx/sites-enabled/default") end
  interpreter "bash"
  user "root"
  code "rm -v default"
  cwd "/etc/nginx/sites-enabled"
end

template "/etc/nginx/sites-available/#{node['portal']['name']}-portal" do
  source "nginx-site.erb"
  owner "root"
  group "root"
  mode 0444
end

script "Enable nginx config" do
  not_if do ::File.symlink?("/etc/nginx/sites-enabled/#{node['portal']['name']}-portal") end
  interpreter "bash"
  user "root"
  cwd "/etc/nginx/sites-enabled/"
  code "ln -sn ../sites-available/#{node['portal']['name']}-portal "
  notifies :restart, "service[nginx]", :immediately
end

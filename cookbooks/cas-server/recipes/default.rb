#
# Cookbook Name:: cas_server
# Recipe:: default
#

# https://launchpad.net/~brightbox/+archive/passenger-nginx
# https://launchpad.net/~brightbox/+archive/ppa

include_recipe "apt"

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

group node["cas_server"]["system_group"] do
  gid node["cas_server"]["system_gid"]
  members 'www-data'
end

user node["cas_server"]["system_user"]  do
  uid node["cas_server"]["system_uid"]
  gid node["cas_server"]["system_gid"]
  home node["cas_server"]["home_dir"]
  system true
  shell "/bin/bash"
  supports :manage_home => true
end

# Try to create databases required for cas_server
ENV['CAS_SERVER_DB_GEN_LOCK'] = "#{node['cas_server']['home_dir']}/.DB_GEN_DONE"
ENV['SQL_DB_NAME'] = node["cas_server"]["sql_db_name"]

if node["cas_server"]["sql_db_create_db"] == true
  if ( node["cas_server"]["sql_db_driver"] == "postgresql" ) and !File.file?("#{node['cas_server']['home_dir']}/.DB_GEN_DONE")

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
    	user node["cas_server"]["system_user"] 
    	cwd "/tmp"
      code <<-EOH
        touch $CAS_SERVER_DB_GEN_LOCK
      EOH
    end
  end
end

# END Try to create databases required for cas_server

directory "#{node['cas_server']['home_dir']}/#{node['cas_server']['name']}" do
  owner node["cas_server"]["system_user"]
  group  node["cas_server"]["system_group"]
  mode 0755
  action :create
end

git "#{node['cas_server']['home_dir']}/#{node['cas_server']['name']}" do
  repository node["cas_server"]["git_repo"] 
  branch node["cas_server"]["git_branch"]
  action :sync
  depth 1
  user    node["cas_server"]["system_user"]
  group   node["cas_server"]["system_group"]
end

directory "#{node['cas_server']['home_dir']}/#{node['cas_server']['name']}/tmp" do
  user    node["cas_server"]["system_user"]
  group   node["cas_server"]["system_group"]
  action :create
  mode 0755
end

directory node["cas_server"]["file_store_location"] do
  owner node["cas_server"]["system_user"]
  group  node["cas_server"]["system_group"]
  mode 0755
  action :create
end

directory "#{node['cas_server']['home_dir']}/#{node['cas_server']['name']}/log" do
  owner node["cas_server"]["system_user"]
  group  node["cas_server"]["system_group"]
  mode 0755
  action :create
end

directory "#{node['cas_server']['home_dir']}/#{node['cas_server']['name']}/tmp/pids" do
  owner node["cas_server"]["system_user"]
  group  node["cas_server"]["system_group"]
  mode 0755
  action :create
  recursive true
end

gem_package "bundler" do
	gem_binary("/usr/bin/gem1.9.3")
	options("--no-rdoc --no-ri")
end

script "Lets get the required GEMS" do
	not_if do ::File.file?('#{node['cas_server']['home_dir']}/#{node['cas_server']['name']}/Gemfile.lock') end
	interpreter "bash"
	user "root"
	cwd "#{node['cas_server']['home_dir']}/#{node['cas_server']['name']}"
	code "bundle --path vendor/bundle --without=sqlite"
end


template "/etc/profile.d/cas_server-enviroment.sh" do
	source "cas_server-enviorment.sh.erb"
	owner "root"
	group "root"
	mode 0444
end

template "/etc/nginx/nginx.conf" do
	source "nginx.conf.erb"
	owner "root"
	group "root"
	mode 0444
end


if ((node["cas_server"]["s3_bucket_name"] != nil) && (node["cas_server"]["s3_access_key_id"] != nil) && (node["cas_server"]["s3_secret_access_key"] != nil))
    template "#{node['cas_server']['home_dir']}/#{node['cas_server']['name']}/config/amazon_s3.yml" do
  	source "amazon-s3.yml.erb"
    owner node["cas_server-ng"]["system_user"]
    group  node["cas_server-ng"]["system_group"]
  	mode 0644
    end
end

template "#{node['cas_server']['home_dir']}/#{node['cas_server']['name']}/config/database.yml" do
	source "database.yml.erb"
  owner node["cas_server"]["system_user"]
  group  node["cas_server"]["system_group"]
	mode 0644
end

template "#{node['cas_server']['home_dir']}/#{node['cas_server']['name']}/config/delayed_jobs.yml" do
	source "delayed_jobs.yml.erb"
  owner node["cas_server"]["system_user"]
  group  node["cas_server"]["system_group"]
	mode 0644
end

template "#{node['cas_server']['home_dir']}/#{node['cas_server']['name']}/config/domain.yml" do
	source "domain.yml.erb"
  owner node["cas_server"]["system_user"]
  group  node["cas_server"]["system_group"]
	mode 0644
end

template "#{node['cas_server']['home_dir']}/#{node['cas_server']['name']}/config/external_migration.yml" do
	source "external_migration.yml.erb"
  owner node["cas_server"]["system_user"]
  group  node["cas_server"]["system_group"]
	mode 0644
end

template "#{node['cas_server']['home_dir']}/#{node['cas_server']['name']}/config/file_store.yml" do
	source "file_store.yml.erb"
  owner node["cas_server"]["system_user"]
  group  node["cas_server"]["system_group"]
	mode 0644
end

template "#{node['cas_server']['home_dir']}/#{node['cas_server']['name']}/config/outgoing_mail.yml" do
	source "outgoing_mail.yml.erb"
  owner node["cas_server"]["system_user"]
  group  node["cas_server"]["system_group"]
	mode 0644
end

template "#{node['cas_server']['home_dir']}/#{node['cas_server']['name']}/config/redis.yml" do
	source "redis.yml.erb"
  owner node["cas_server"]["system_user"]
  group  node["cas_server"]["system_group"]
	mode 0644
end

template "#{node['cas_server']['home_dir']}/#{node['cas_server']['name']}/config/security.yml" do
	source "security.yml.erb"
  owner node["cas_server"]["system_user"]
  group  node["cas_server"]["system_group"]
	mode 0644
end

script "Compile Assets" do
	interpreter "bash"
	cwd "#{node['cas_server']['home_dir']}/#{node['cas_server']['name']}"
	not_if do ::File.directory?("#{node['cas_server']['home_dir']}/#{node['cas_server']['name']}/public/assets") end
	code "bundle exec rake cas_server:compile_assets"
end

script "Compress Assets" do
	interpreter "bash"
	cwd "#{node['cas_server']['home_dir']}/#{node['cas_server']['name']}"
	code "bundle exec rake cas_server:compress_assets"
end

script "Remove old Nginx factory config" do
  only_if do ::File.symlink?( "/etc/nginx/sites-enabled/default") end
  interpreter "bash"
  user "root"
  code "rm -v default"
  cwd "/etc/nginx/sites-enabled"
end

template "/etc/nginx/sites-available/cas_server" do
  source "nginx-site.erb"
  owner "root"
  group "root"
  mode 0444
end

script "Enable nginx config" do
  not_if do ::File.symlink?('/etc/nginx/sites-enabled/cas_server') end  
  interpreter "bash"
  user "root"
  cwd "/etc/nginx/sites-enabled/"
  code "ln -sn ../sites-available/cas_server "
  notifies :restart, "service[nginx]", :immediately
end

#
# Cookbook Name:: canvas
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

%w( ruby1.9.3 zlib1g-dev libxml2-dev libmysqlclient-dev libxslt1-dev 
 imagemagick libpq-dev nodejs libxmlsec1-dev libcurl4-gnutls-dev 
 libxmlsec1 build-essential openjdk-7-jre git-core zip unzip
 libpq-dev nodejs passenger-common1.9.1 ruby-switch nginx-full ).each do |pkg|; package pkg; end

service "nginx" do
  action :nothing
  supports :status => true, :start => true, :stop => true, :restart => true
end

group node["canvas"]["system_group"] do
  gid node["canvas"]["system_gid"]
  members 'www-data'
end

user node["canvas"]["system_user"]  do
  uid node["canvas"]["system_uid"]
  gid node["canvas"]["system_gid"]
  home node["canvas"]["home_dir"]
  system true
  shell "/bin/bash"
  supports :manage_home => true
end

# Try to create databases required for canvas
ENV['CANVAS_DB_GEN_LOCK'] = "#{node["canvas"]["home_dir"]}/.DB_GEN_DONE"
ENV['SQL_DB_NAME'] = node["canvas"]["sql_db_name"]
ENV['SQL_QUEUE_DB_NAME'] = node["canvas"]["sql_queue_db_name"] 

if node["canvas"]["sql_db_create_db"] == true
  if ( node["canvas"]["sql_db_driver"] == "postgresql" ) and !File.file?("#{node["canvas"]["home_dir"]}/.DB_GEN_DONE")

    script "Create Postgres Databases" do
      interpreter "bash"
    	user "postgres"
    	cwd "/tmp"
      code <<-EOH
         /usr/bin/createdb $SQL_DB_NAME
         /usr/bin/createdb $SQL_QUEUE_DB_NAME
      EOH
    end

    script "Create DB Lock File" do
      interpreter "bash"
    	user node["canvas"]["system_user"] 
    	cwd "/tmp"
      code <<-EOH
        touch $CANVAS_DB_GEN_LOCK
      EOH
    end

  end
end

# END Try to create databases required for canvas

directory "#{node["canvas"]["home_dir"]}/lms" do
  owner node["canvas"]["system_user"]
  group  node["canvas"]["system_group"]
  mode 0755
  action :create
end

git "#{node["canvas"]["home_dir"]}/lms" do
  repository node["canvas"]["git_repo"] 
  branch node["canvas"]["git_branch"]
  action :sync
  depth 1
  user    node["canvas"]["system_user"]
  group   node["canvas"]["system_group"]
end

directory "#{node["canvas"]["home_dir"]}/lms/tmp" do
  user    node["canvas"]["system_user"]
  group   node["canvas"]["system_group"]
  action :create
  mode 0755
end

directory node["canvas"]["file_store_location"] do
  owner node["canvas"]["system_user"]
  group  node["canvas"]["system_group"]
  mode 0755
  action :create
end

directory "#{node["canvas"]["home_dir"]}/lms/log" do
  owner node["canvas"]["system_user"]
  group  node["canvas"]["system_group"]
  mode 0755
  action :create
end

directory "#{node["canvas"]["home_dir"]}/lms/tmp/pids" do
  owner node["canvas"]["system_user"]
  group  node["canvas"]["system_group"]
  mode 0755
  action :create
  recursive true
end

gem_package "bundler" do
	gem_binary("/usr/bin/gem1.9.3")
	options("--no-rdoc --no-ri")
end

script "Lets get the required GEMS" do
	not_if do ::File.file?('#{node["canvas"]["home_dir"]}/lms/Gemfile.lock') end
	interpreter "bash"
	user "root"
	cwd "#{node["canvas"]["home_dir"]}/lms"
	code "bundle --path vendor/bundle --without=sqlite"
end


template "/etc/profile.d/canvas-enviroment.sh" do
	source "canvas-enviorment.sh.erb"
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


if ((node["canvas"]["s3_bucket_name"] != nil) && (node["canvas"]["s3_access_key_id"] != nil) && (node["canvas"]["s3_secret_access_key"] != nil))
    template "#{node["canvas"]["home_dir"]}/lms/config/amazon_s3.yml" do
  	source "amazon-s3.yml.erb"
    owner node["canvas-ng"]["system_user"]
    group  node["canvas-ng"]["system_group"]
  	mode 0644
    end
end

template "#{node["canvas"]["home_dir"]}/lms/config/database.yml" do
	source "database.yml.erb"
  owner node["canvas"]["system_user"]
  group  node["canvas"]["system_group"]
	mode 0644
end

template "#{node["canvas"]["home_dir"]}/lms/config/delayed_jobs.yml" do
	source "delayed_jobs.yml.erb"
  owner node["canvas"]["system_user"]
  group  node["canvas"]["system_group"]
	mode 0644
end

template "#{node["canvas"]["home_dir"]}/lms/config/domain.yml" do
	source "domain.yml.erb"
  owner node["canvas"]["system_user"]
  group  node["canvas"]["system_group"]
	mode 0644
end

template "#{node["canvas"]["home_dir"]}/lms/config/external_migration.yml" do
	source "external_migration.yml.erb"
  owner node["canvas"]["system_user"]
  group  node["canvas"]["system_group"]
	mode 0644
end

template "#{node["canvas"]["home_dir"]}/lms/config/file_store.yml" do
	source "file_store.yml.erb"
  owner node["canvas"]["system_user"]
  group  node["canvas"]["system_group"]
	mode 0644
end

template "#{node["canvas"]["home_dir"]}/lms/config/outgoing_mail.yml" do
	source "outgoing_mail.yml.erb"
  owner node["canvas"]["system_user"]
  group  node["canvas"]["system_group"]
	mode 0644
end

template "#{node["canvas"]["home_dir"]}/lms/config/redis.yml" do
	source "redis.yml.erb"
  owner node["canvas"]["system_user"]
  group  node["canvas"]["system_group"]
	mode 0644
end

template "#{node["canvas"]["home_dir"]}/lms/config/security.yml" do
	source "security.yml.erb"
  owner node["canvas"]["system_user"]
  group  node["canvas"]["system_group"]
	mode 0644
end

script "Compile Assets" do
	interpreter "bash"
	cwd "#{node["canvas"]["home_dir"]}/lms"
	not_if do ::File.directory?("#{node["canvas"]["home_dir"]}/lms/public/assets") end
	code "bundle exec rake canvas:compile_assets"
end

script "Compress Assets" do
	interpreter "bash"
	cwd "#{node["canvas"]["home_dir"]}/lms"
	code "bundle exec rake canvas:compress_assets"
end

script "Remove old Nginx factory config" do
  only_if do ::File.symlink?( "/etc/nginx/sites-enabled/default") end
  interpreter "bash"
  user "root"
  code "rm -v default"
  cwd "/etc/nginx/sites-enabled"
end

template "/etc/nginx/sites-available/canvas" do
  source "nginx-site.erb"
  owner "root"
  group "root"
  mode 0444
end

script "Enable nginx config" do
  not_if do ::File.symlink?('/etc/nginx/sites-enabled/canvas') end  
  interpreter "bash"
  user "root"
  cwd "/etc/nginx/sites-enabled/"
  code "ln -sn ../sites-available/canvas "
  notifies :restart, "service[nginx]", :immediately
end

ENV['CANVAS_INIT'] = "#{node["canvas"]["home_dir"]}/lms/script/canvas_init"
script "Link canvas_init" do
  not_if do ::File.symlink?('/etc/init.d/canvas_init') end  
	interpreter "bash"
	user "root"
	cwd "/tmp"
	code "ln -s $CANVAS_INIT /etc/init.d/canvas_init"
end


service "canvas_init" do
  action :nothing
  supports :status => true, :start => true, :stop => true, :restart => true
end

script "enable canvas_init during boot" do
  not_if do ::File.symlink?('/etc/rc2.d/S20canvas_init') end  
	interpreter "bash"
	user "root"
	cwd "/tmp"
	code "update-rc.d canvas_init defaults"
	notifies :start, "service[canvas_init]", :immediately
end

#See if we should install QTI Tools

if node["canvas"]["install_qti_tools"] == true

  directory "#{node["canvas"]["home_dir"]}/lms/vendor/QTIMigrationTool" do
    owner node["canvas"]["system_user"]
    group  node["canvas"]["system_group"]
    mode 0755
    action :create
  end

  git "#{node["canvas"]["home_dir"]}/lms/vendor/QTIMigrationTool" do
    repository node["canvas"]["qti_git_repo"]
    branch node["canvas"]["qti_git_branch"]
    action :sync
    depth 1
    user    node["canvas"]["system_user"]
    group   node["canvas"]["system_group"]
    notifies :start, "service[canvas_init]", :immediately
  	
  end
  
end


# End QTI tools







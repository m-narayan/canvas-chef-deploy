#
# Cookbook Name:: canvas
# Recipe:: default
#

# Ubuntu's 1.9.3 ruby packages are called 1.9.1 <<---- 


%w( ruby1.9.1 ruby1.9.1-dev rubygems1.9.1 irb1.9.1 ri1.9.1 rdoc1.9.1
  build-essential libopenssl-ruby1.9.1 libssl-dev 
  zlib1g-dev rubygems libxml2-dev git-core openjdk-7-jre zip unzip
  libmysqlclient-dev libxslt1-dev libsqlite3-dev libhttpclient-ruby nano imagemagick libssl-dev
  irb libpq-dev nodejs libxmlsec1-dev libcurl4-openssl-dev
  ).each do |pkg|; package pkg; end

#chmod o+w  /opt/canvas/lms/tmp

include_recipe "nginx::default"

#script "Set Default Ruby for your system" do
#	interpreter "bash"
#	user "root"
#	cwd "/tmp"
#	code "update-alternatives --set ruby /usr/bin/ruby1.9.1"
#end

#gem_package "chef" do
#	gem_binary("/usr/bin/gem1.9.1")
#	options("--no-rdoc --no-ri")
#end

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
	gem_binary("/usr/bin/gem1.9.1")
	options("--no-rdoc --no-ri")
end

gem_package "debugger" do
	gem_binary("/usr/bin/gem1.9.1")
	options("--no-rdoc --no-ri")
end
    
script "Lets get the required GEMS" do
	not_if do ::File.file?('#{node["canvas"]["home_dir"]}/lms/Gemfile.lock') end
	interpreter "bash"
	user "root"
	cwd "#{node["canvas"]["home_dir"]}/lms"
	code "bundle"
end

template "#{node["canvas"]["home_dir"]}/lms/script/delayed_job" do
	source "script-delayed_job.erb"
	owner "canvas"
	group "canvas"
	mode 0755
end

template "/etc/profile.d/canvas-enviroment.sh" do
	source "canvas-enviorment.sh.erb"
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


script "Remove old Nginx factory config" do
  only_if do ::File.symlink?( "/etc/nginx/sites-enabled/000-default") end
  interpreter "bash"
  user "root"
  code <<-EOH
    nxdissite default
  EOH
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
  cwd "/tmp"
  code "nxensite canvas"
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







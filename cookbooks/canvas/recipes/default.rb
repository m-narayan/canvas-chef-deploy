#
# Cookbook Name:: canvas
# Recipe:: default
#

# Ubuntu's 1.9.3 ruby packages are called 1.9.1 <<---- 


%w( ruby1.9.1 ruby1.9.1-dev rubygems1.9.1 irb1.9.1 ri1.9.1 rdoc1.9.1
  build-essential libopenssl-ruby1.9.1 libssl-dev 
  zlib1g-dev rake rubygems libxml2-dev git-core openjdk-7-jre zip unzip
  libmysqlclient-dev libxslt1-dev libsqlite3-dev libhttpclient-ruby nano imagemagick libssl-dev
  irb libpq-dev nodejs libxmlsec1-dev libcurl4-openssl-dev apache2 libapache2-mod-passenger
  ).each do |pkg|; package pkg; end


script "Update default gem" do
  not_if do ::File.readlink("/etc/alternatives/gem") == "/usr/bin/gem1.9.1"; end
  interpreter "bash"
	user "root"
	cwd "/tmp"
  code <<-EOH
      /usr/sbin/update-alternatives  --set gem /usr/bin/gem1.9.1 
  EOH
end

script "Update default Ruby" do
  not_if do ::File.readlink("/etc/alternatives/ruby") == "/usr/bin/ruby1.9.1"; end
  interpreter "bash"
	user "root"
	cwd "/tmp"
  code <<-EOH
      /usr/sbin/update-alternatives  --set ruby /usr/bin/ruby1.9.1
  EOH
end

service "apache2" do
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

directory "#{node["canvas"]["home_dir"]}/apache_logs" do
  owner node["canvas"]["system_user"]
  group  node["canvas"]["system_group"]
  mode 0755
  action :create
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

script "Gem install Bundler" do
  not_if do ::File.file?('/usr/local/bin/bundle') end
  interpreter "bash"
	user "root"
	cwd "/tmp"
  code <<-EOH
      /bin/bash -ls -c "gem install bundle --no-rdoc --no-ri"
  EOH
end

script "Lets get the required GEMS" do
  not_if do ::File.file?('#{node["canvas"]["home_dir"]}/lms/Gemfile.lock') end
  interpreter "bash"
	user "root"
	cwd "#{node["canvas"]["home_dir"]}/lms"
  code <<-EOH
     /usr/local/bin/bundle install
  EOH
end

template "/etc/profile.d/canvas-enviroment.sh" do
	source "canvas-enviorment.sh.erb"
	owner "root"
	group "root"
	mode 0444
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
	user node["canvas"]["system_user"]
	cwd "#{node["canvas"]["home_dir"]}/lms"
	not_if do ::File.directory?("#{node["canvas"]["home_dir"]}/lms/public/assets") end
  code <<-EOH
      /usr/local/bin/bundle exec rake canvas:compile_assets
  EOH
end

script "Enable required apache passenger module" do
  interpreter "bash"
	user "root"
	cwd "/tmp"
	not_if do ::File.symlink?('/etc/apache2/mods-enabled/passenger.load') end
  code <<-EOH
    /bin/bash -ls -c "a2enmod passenger"
  EOH
end

script "enable required apache rewrite module" do
  interpreter "bash"
	user "root"
	cwd "/tmp"
	not_if do ::File.symlink?('/etc/apache2/mods-enabled/rewrite.load') end
  code <<-EOH
    /bin/bash -ls -c "a2enmod rewrite"
  EOH
end

script "enable required apache ssl module" do
  interpreter "bash"
	user "root"
	cwd "/tmp"
	not_if do ::File.symlink?('/etc/apache2/mods-enabled/ssl.load') end
  code <<-EOH
    /bin/bash -ls -c "a2enmod ssl"
  EOH
end

script "Remove old apache factory config" do
  only_if do ::File.symlink?( "/etc/apache2/sites-enabled/000-default") end
  interpreter "bash"
  user "root"
  code <<-EOH
    a2dissite default
  EOH
end

template "/etc/apache2/sites-available/canvas-apache.conf" do
  source "canvas-apache.conf.erb"
	owner "root"
	group "root"
	mode 0444
end

script "Enable apache config" do
  not_if do ::File.symlink?('/etc/apache2/sites-enabled/canvas-apache.conf') end  
	interpreter "bash"
	user "root"
	cwd "/tmp"
	code "a2ensite canvas-apache.conf"
  notifies :restart, "service[apache2]", :immediately
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







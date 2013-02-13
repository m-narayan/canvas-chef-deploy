%w( ruby1.9.1 ruby1.9.1-dev rubygems1.9.1 irb1.9.1 ri1.9.1 rdoc1.9.1
  build-essential libopenssl-ruby1.9.1 libssl-dev 
  zlib1g-dev rake rubygems libxml2-dev ).each do |pkg|; package pkg; end


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

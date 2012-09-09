file_cache_path  "/tmp/chef-solo"
cookbook_path     "#{Dir.getwd}/cookbooks"
data_bag_path     "#{Dir.getwd}/data-bags"
log_level        :info
log_location     STDOUT
ssl_verify_mode  :verify_none
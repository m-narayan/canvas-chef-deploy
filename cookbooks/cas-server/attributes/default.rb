#System user to create and use for cas_server
default["cas_server"]["system_user"]  = "sysadmin"
default["cas_server"]["system_group"] = "sysadmin"
default["cas_server"]["system_uid"]   = 400
default["cas_server"]["system_gid"]   = 400
default["cas_server"]["home_dir"]     = "/var/cas_server"
default["cas_server"]["url"]     = "setme"

#GIT Repo Settings
default["cas_server"]["git_repo"]     = "https://github.com/m-narayan/rubycas-server.git"
default["cas_server"]["git_branch"]   = "deploy"

#CAS SQL Server Settings
default["cas_server"]["sql_user"]     = "setme"
default["cas_server"]["sql_password"] = "setme"
default["cas_server"]["sql_server"]   = "127.0.0.1"
default["cas_server"]["sql_db_name"]  = "cas_production"
default["cas_server"]["sql_db_timeout"]     = 5000
default["cas_server"]["sql_db_driver"]      = "postgresql"
default["cas_server"]["sql_db_create_db"]   = false

# portal user table access details
default["cas_server"]["portal_sql_user"]     = "setme"
default["cas_server"]["portal_sql_password"] = "setme"
default["cas_server"]["portal_sql_server"]   = "127.0.0.1"
default["cas_server"]["portal_sql_db_name"]  = "portal_production"

#General cas_server Settings
default["cas_server"]["fqdn"] = "cas.local"
default["cas_server"]["ssl_key"] = "/etc/ssl/private/ssl-cert-snakeoil.key"
default["cas_server"]["ssl_cert"] = "/etc/ssl/certs/ssl-cert-snakeoil.pem"
default["cas_server"]["ruby_bin"] = "/usr/bin/ruby1.9.1"
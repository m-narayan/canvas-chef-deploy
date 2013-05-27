#System user to create and use for portal
default["portal"]["system_user"]  = "sysadmin"
default["portal"]["system_group"] = "sysadmin"
default["portal"]["system_uid"]   = 400
default["portal"]["system_gid"]   = 400
default["portal"]["home_dir"]     = "/var/portal"
default["portal"]["name"]     = "setme"

#GIT Repo Settings
default["portal"]["git_repo"]     = "https://github.com/m-narayan/beacon.git"
default["portal"]["git_branch"]   = "deploy"

#SQL Server Settings
default["portal"]["sql_user"]     = "setme"
default["portal"]["sql_password"] = "setme"
default["portal"]["sql_server"]   = "127.0.0.1"
default["portal"]["sql_db_name"]  = "portal_production"
default["portal"]["sql_db_timeout"]     = 5000
default["portal"]["sql_db_driver"]      = "postgresql"
default["portal"]["sql_db_create_db"]   = false

#Outoging Mail Setttings
default["portal"]["use_sendmail"] = true
default["portal"]["outgoing_mail_server"] = "smtp.somedomain.com"
default["portal"]["outgoing_mail_server_port"] = 25
default["portal"]["outgoing_mail_server_user"] = "sombody"
default["portal"]["outgoing_mail_server_password"] = "setme"
default["portal"]["outgoing_mail_server_auth_method"] = "none"
default["portal"]["outgoing_mail_server_domain"] = "example.com"
default["portal"]["outgoing_mail_server_email_address"] = "portal@example.com"
default["portal"]["outgoing_mail_server_email_name"] = "The Learnistute"

#ominiauth portal Settings
default["portal"]["omniauth_facebook_key"] = "setme"
default["portal"]["omniauth_facebook_secret"] = "setme"
default["portal"]["omniauth_linkedin_key"] = "setme"
default["portal"]["omniauth_linkedin_secret"] = "setme"
default["portal"]["omniauth_google_oauth2_key"] = "setme"
default["portal"]["omniauth_google_oauth2_secret"] = "setme"

#cas_server portal settings
default["portal"]["cas_server_enable"] = "true"
default["portal"]["cas_server_url"] = "setme"

#lms portal settings
default["portal"]["lms_enable"] = "true"
default["portal"]["lms_account_id"] = "setme"
default["portal"]["lms_oauth_token"] = "setme"
default["portal"]["lms_root_url"] = "setme"

#General portal Settings
default["portal"]["fqdn"] = "portal.local"
default["portal"]["ssl_key"] = "/etc/ssl/private/ssl-cert-snakeoil.key"
default["portal"]["ssl_cert"] = "/etc/ssl/certs/ssl-cert-snakeoil.pem"
default["portal"]["ruby_bin"] = "/usr/bin/ruby1.9.1"

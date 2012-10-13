#System user to create and use for canvas
default["canvas"]["system_user"]  = "canvas"
default["canvas"]["system_group"] = "canvas"
default["canvas"]["system_uid"]   = 400
default["canvas"]["system_gid"]   = 400
default["canvas"]["home_dir"]     = "/opt/canvas"

#GIT Repo Settings
default["canvas"]["git_repo"]     = "https://github.com/instructure/canvas-lms.git"
default["canvas"]["git_branch"]   = "stable"

#SQL Server Settings
default["canvas"]["sql_user"]     = "setme"
default["canvas"]["sql_password"] = "setme"
default["canvas"]["sql_server"]   = "setme"
default["canvas"]["sql_db_name"]  = "canvas_production"
default["canvas"]["sql_queue_db_name"]  = "canvas_queue_production"
default["canvas"]["sql_db_timeout"]     = 5000
default["canvas"]["sql_db_driver"]      = "postgresql" #can be mysql as well
default["canvas"]["sql_db_create_db"]   = false

#Outoging Mail Setttings
default["canvas"]["use_sendmail"] = true
default["canvas"]["outgoing_mail_server"] = "smtp.somedomain.com"
default["canvas"]["outgoing_mail_server_port"] = 25
default["canvas"]["outgoing_mail_server_user"] = "sombody"
default["canvas"]["outgoing_mail_server_password"] = "setme"
default["canvas"]["outgoing_mail_server_auth_method"] = "none" # can be: plain, login, or cram_md5
default["canvas"]["outgoing_mail_server_domain"] = "example.com"
default["canvas"]["outgoing_mail_server_email_address"] = "canvas@example.com"
default["canvas"]["outgoing_mail_server_email_name"] = "The Learnistute"

# QTI TOOLS
default["canvas"]["install_qti_tools"] = false
default["canvas"]["qti_git_repo"] = "https://github.com/instructure/QTIMigrationTool.git"
default["canvas"]["qti_git_branch"] = "master"


#General Canvas Settings
default["canvas"]["redis_server"]       = "setme"
default["canvas"]["fqdn"] = "canvas.local"
default["canvas"]["random_key"] = "you-really-need-to-set-me"
default["canvas"]["file_store_location"] = "/opt/canvas/lms/file_store"
default["canvas"]["apache_ssl_key"] = "/etc/ssl/private/ssl-cert-snakeoil.key"
default["canvas"]["apache_ssl_cert"] = "/etc/ssl/certs/ssl-cert-snakeoil.pem"
default["canvas"]["apache_ssl_chain"] = "NOCA" # use "NOCA" if you do not have an SSL Certificate Chain File

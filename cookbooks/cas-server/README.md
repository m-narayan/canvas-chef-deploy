Description
===========

Opscode Cookbook for installing Ruby CAS server

Requirements
============
* Fresh install of ubuntu 64bit 12.04LTS, This will not work with older versions.
* Internet access 
* Postgres

Attributes
==========
Below are the default values for the attribues being used in this cookbook

**System user to create and use for canvas**
* ["canvas"]["system_user"]  = "canvas"
* ["canvas"]["system_group"] = "canvas"
* ["canvas"]["system_uid"]   = 400
* ["canvas"]["system_gid"]   = 400
* ["canvas"]["home_dir"]     = "/opt/canvas"

**GIT Repo Settings**
* ["canvas"]["git_repo"]     = "https://github.com/instructure/canvas-lms.git"
* ["canvas"]["git_branch"]   = "stable"

**SQL Server Settings**
* ["canvas"]["sql_user"]     = "setme"
* ["canvas"]["sql_password"] = "setme"
* ["canvas"]["sql_server"]   = "setme"
* ["canvas"]["sql_db_name"]  = "canvas_production"
* ["canvas"]["sql_queue_db_name"]  = "canvas_queue_production"
* ["canvas"]["sql_db_timeout"]     = 5000
* ["canvas"]["sql_db_driver"]      = "postgresql" #can be mysql as well
* ["canvas"]["sql_db_create_db"]   = false

**Outoging Mail Setttings**
* ["canvas"]["use_sendmail"] = true , Set to false if you want Cavas to send its mail via a external mail server
* ["canvas"]["outgoing_mail_server"] = "smtp.somedomain.com"
* ["canvas"]["outgoing_mail_server_port"] = 25
* ["canvas"]["outgoing_mail_server_user"] = "sombody"
* ["canvas"]["outgoing_mail_server_password"] = "setme"
* ["canvas"]["outgoing_mail_server_auth_method"] = "none" # can be: plain, login, or cram_md5
* ["canvas"]["outgoing_mail_server_domain"] = "example.com"
* ["canvas"]["outgoing_mail_server_email_address"] = "canvas@example.com"
* ["canvas"]["outgoing_mail_server_email_name"] = "The Learnistute"

**QTI TOOLS**
* ["canvas"]["install_qti_tools"] = false, I recomend setting this to true
* ["canvas"]["qti_git_repo"] = "https://github.com/instructure/QTIMigrationTool.git"
* ["canvas"]["qti_git_branch"] = "master"

**General Canvas Settings**
* ["canvas"]["redis_server"] = "setme"
* ["canvas"]["fqdn"] = "canvas.local" (for production this should be your DNS name for Canvas!)
* ["canvas"]["random_key"] = "you-really-need-to-set-me"
* ["canvas"]["file_store_location"] = "/opt/canvas/lms/file_store"
* ["canvas"]["ssl_key"] = "/etc/ssl/private/ssl-cert-snakeoil.key"
* ["canvas"]["ssl_cert"] = "/etc/ssl/certs/ssl-cert-snakeoil.pem"


Usage
=====


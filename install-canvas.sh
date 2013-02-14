#!/bin/bash

#!/bin/bash
#####################################################
# Created by 
#	Neal Ogg Lawson <neal.lawson@gmail.com>
# 
# This script is to help with the bootstrap process of
# installing canvas. 
######################################################
export DEBIAN_FRONTEND=noninteractive
shopt -s -o nounset
declare -rx SCRIPT=${0##*/}
CHEF_SOLO_CONFIG="chef-solo-config.rb"
RUN_LIST="node-canvas.json"
REQURIED_PACKAGES="rubygems joe chef"

if [ $# -eq 0 ] ; then
   printf "%s\n" "Type -h for help."
   exit 192
fi


function ihascrashed() {
	echo 
	echo "Hmm, Somthing seems to have gone wrong, you need to find out what happend."
	echo "Before proceeding. Sorry Dude!"
	echo 
	exit 1
}

function help() {
	echo 
	echo "Welcome to help!, if your reading this you may need Help!"
	echo "This script requires root privlieges and will exit with out root!"

	echo "options:"
	echo -e "\t-h Display this help"
	echo -e "\t-i Install Canvas"
	echo
}

function display_finishup_directions() {
	echo ""
	echo "Alright, we are almost done, but we need to do some intial tasks!"
	echo "Fist we need to populate the database with some inital data"
	echo "in /opt/canvas/lms (unless you have altered your canvas home)"
	echo ""
	echo "RUN: sudo -u canvas /bin/bash -c \"( cd /opt/canvas/lms && RAILS_ENV=production bundle exec rake db:initial_setup ) \""
	echo ""
	echo "Now, we need to restart nginx and canvas_init...."
	echo ""
	echo "RUN: sudo /etc/init.d/nginx restart"
	echo "RUN: sudo /etc/init.d/canvas_init restart"
	echo ""
	echo "you should now have a working canvas install (At least i hope so!)"
}

function setup_apt_opscode() {
	echo "Checking if we need to setup an Apt repo for OPSCODE"
	if test -f /etc/apt/sources.list.d/opscode.list; then 
		echo "opscode Repo has already been configured"
	else
		echo "Setting up opscode repo"
		echo "deb http://apt.opscode.com/ `lsb_release -cs`-0.10 main" | sudo tee /etc/apt/sources.list.d/opscode.list
		gpg --keyserver keys.gnupg.net --recv-keys 83EF826A
		gpg --export packages@opscode.com | sudo tee /etc/apt/trusted.gpg.d/opscode-keyring.gpg > /dev/null
		DEBIAN_FRONTEND=noninteractive apt-get update && DEBIAN_FRONTEND=noninteractive apt-get upgrade
		
	fi
	
}

function run_chef_solo() {
	echo "Running Chef:"
	chef-solo -c $CHEF_SOLO_CONFIG -j $RUN_LIST
	if [ $? -eq 0 ];then
	   echo "Chef has run Sucessfully!"
	else
	   ihascrashed
	fi
}

function install() {
	echo -n "Are we running as root? "
	if [ $USER != "root" ]; then
		echo "NO!"
		echo "I need to run as root!, hint: sudo $0"
		exit 192
	else
		echo "Yah!, lets install!"
	fi
	
	setup_apt_opscode
	
	echo "Instailling required packages! (${REQURIED_PACKAGES})"
	DEBIAN_FRONTEND=noninteractive apt-get install -q -y --force-yes $REQURIED_PACKAGES
	
	run_chef_solo
	display_finishup_directions
}




while getopts "hi" SWITCH ; do
	case $SWITCH in
		h) help;exit 0;;
		i) install;exit 0;;
		\?) exit 192;;

		*) printf "$SCRIPT:$LINENO: %s\n" "script error: unhandled argument"
			exit 192
     		;;
  	esac
done


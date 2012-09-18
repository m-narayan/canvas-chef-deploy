chef-canvas
===========

Chef-Solo scripts to deploy Instructure Canvas on a Ubuntu 12.04LTS 64bit Machine

Instructions
===========
Make sure the data in node-canvas.json is good for your setup.  

One thing you will likely wish to change is the FQDN parameter to tell apache where to host yourcanvas.yourdomain.com  


1. Clone the repo to your local machine
	```bash
	git clone https://github.com/neallawson/chef-canvas.git
	```
		
2. Update your configs
	```bash
	cd chef-canvas
	vim node-canvas.json
	```

3. Run the install ( Be sure your running this from the directory you cloned this project into.... )
	```bash
	sudo ./install-canvas.sh -i
	```

4. Populate the Database
	```bash
	cd /opt/canvas/lms
	RAILS_ENV=production bundle exec rake db:initial_setup
	```

5. Restart Apache & Reddis
	```bash
	sudo /etc/init.d/apache2 restart
	sudo /etc/init.d/canvas_init restart
	```

chef-deploy-scripts for arrivu applications
===========

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
	 sudo -u canvas /bin/bash -c "( cd /opt/canvas/lms && RAILS_ENV=production bundle exec rake db:initial_setup ) "
	```

5. Restart Nginx & Canvas_init
	```bash
	sudo /etc/init.d/nginx restart
	sudo /etc/init.d/canvas_init restart
	```

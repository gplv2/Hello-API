## Content

This vagrant is specifically setup to use nginx, mariadb / postgres , php-fpm .  The reason is that standard homestead does not take care of bringing the OS up to date. 0.5 left package management broken in my experience so I started writing a fix script, that eventually became a custom provisioner.  The goal making it was to reuse the homestead box , since it is a good start.  But we will update/upgrade it on OS level. Also add specific software and last but note least: deploy the full app from a git clone and not from a shared dir.

The reason to not use the shared directory as base of our application is that often versions differ between where you work (usually host) and the platform you test. Accidently dumping composer autoload on the host can have strange consequences.  It is better to start totally fresh on a VM.

* [Features](#VagrantFeatures)
* [Requirements](#VagrantRequirements)
* [Instructions](#VagrantInstructions)

<a name="VagrantFeatures"></a>
## Main Features

* Do networking correct (include a bridge)
* Deploys MariaDB 10.2 or Postgres database
* Uses NGINX webserver + PHP/FPM
* PHP 7.0
* Deploys the app (check repo url)
* Triggers right composer + artisan commands to correctly deploy

### single configuration location 

with the env plugin, we can reuse .env.example to deploy our app.  So you clone the Hello-Api repository, make a copy of the example to .env and edit your preferences, then do `vagrant up`.  You need to be aware that any .env is excluded in being commited to git.  Changes you make in the .env file remain local changes.  But you don't need this to deploy your application. The default example file works out of the box. If you want to change this , you'll need to fork the repository and change the .env.example. Currently the repository is still hardcoded but that will change.

<a name="VagrantRequirements"></a>
## Minimum requirements

* Homestead/laravel 0.5+
* Virtualbox 5.1.8+
* Vagrant 1.8.7

If vagrant is not up to date, chances are your VM will not be able to establish ssh communications due to key problems (the fall back will not work).  Upgrading to atleast those will make it work. getting this to work from 0.5 to 0.6 took more time that getting it run with 0.5 alone.

<a name="VagrantPlugin"></a>
### install env plugin

Install the lastest version of [vagrant-env plugin](https://github.com/gosuri/vagrant-env). 

    $ vagrant plugin install vagrant-env

<a name="VagrantInstructions"></a>
## Vagrant instructions

Now , it will use your .env file to create a vagrant setup, make sure you have one, at the very least you would copy the example over. This will not be automated, the dark side of the force is too strong here.

### vagrant run
    $ vagrant up

You will see all the provisioning tasks to ensure php/laravel etc is running decently on Ubuntu 16.04 custom homestead machine.

### vagrant ssh


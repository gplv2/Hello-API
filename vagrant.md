## Vagrant instructions

### Minimum requirements

* Homestead/laravel 0.5+
* Virtualbox 5.1.8+
* Vagrant 1.8.7

If vagrant is not up to date, chances are your VM will not be able to establish ssh communications due to key problems.  Upgrading to atleast those will make it work.

### install env plugin

Install the lastest version of [vagrant-env plugin](https://github.com/gosuri/vagrant-env). 

    $ vagrant plugin install vagrant-env

Now , it will use your .env file to create a vagrant setup, make sure you have one, at the very least you would copy the example over. This will not be automated, the dark side of the force is too strong here.

### vagrant run
    $ vagrant up

You will see all the ubuntu extra fixes we made to ensure php/laravel etc is running decently on Ubuntu 16.04

### vagrant ssh

## Content

* [Vagrant](#VagrantFeatures)

<a name="VagrantFeatures"></a>


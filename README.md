<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**

- [Guifi Development Kit (GDK)](#guifi-development-kit-gdk)
- [Pre-requisites](#pre-requisites)
  - [Installation on Debian 8 Jessie](#installation-on-debian-8-jessie)
    - [VirtualBox](#virtualbox)
    - [Vagrant](#vagrant)
  - [Installation on Debian 9 Stretch](#installation-on-debian-9-stretch)
    - [VirtualBox](#virtualbox-1)
    - [Vagrant](#vagrant-1)
  - [MacOS X](#macos-x)
    - [VirtualBox](#virtualbox-2)
    - [Vagrant](#vagrant-2)
- [Preparing the environment](#preparing-the-environment)
- [Deployment](#deployment)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

Guifi Development Kit (GDK)
===========================

The Guifi Development Kit sets up a development environment for the Guifi.net website using Vagrant on a VirtualBox virtual machine, where the host and guest machines share three folders:
* Guifi Drupal module
* Guifi Budgets Drupal module
* Guifi 2011 Drupal Theme

# Pre-requisites

The GDK uses Vagrant and VirtualBox, as well as some libraries and packages like zlib1g-dev and Git.

## Installation on Debian 8 Jessie

To set up the GDK on a Debian 8 Jessie host, run the following steps to install the required packages.

### VirtualBox
Activate the "contrib" section in ``/etc/apt/sources.list``:
```
deb http://http.debian.net/debian/ jessie main contrib
```
Update the packages repository 
```
apt-get update
```
Install VirtualBox and the Linux headers packages for your host:
```
apt-get install linux-headers-$(uname -r|sed 's,[^-]*-[^-]*-,,') virtualbox
```
### Vagrant
Install Vagrant and the required libraries and packages:
```
apt-get install vagrant zlib1g-dev git
```
## Installation on Debian 9 Stretch

To set up the GDK on a Debian 9 Stretch host, run the following steps to install the required packages.

### VirtualBox

Edit this file with `editor /etc/apt/sources.list.d/vagrant.list` and add this line:
```
deb http://download.virtualbox.org/virtualbox/debian stretch contrib
```
Add Oracle Virtualbox repo public key:
```
curl -O https://www.virtualbox.org/download/oracle_vbox_2016.asc
sudo apt-key add oracle_vbox_2016.asc
```
Update the packages repository and install virtualbox
```
apt-get update
apt-get install virtualbox-5.1
```

src https://wiki.debian.org/VirtualBox#Debian_9_.22Stretch.22

### Vagrant
Install Vagrant and the required libraries and packages:
```
apt-get install vagrant zlib1g-dev git
```

## MacOS X

### VirtualBox
Download from [Virtualbox page](https://www.virtualbox.org/wiki/Downloads)

### Vagrant
Download from [Vagrant page](https://www.vagrantup.com/downloads.html)

# Preparing the environment

The environment will be built in a folder named "guifi_dev". You can choose another name, if you prefer. Start by creating it and cloning the GDK repository there:
```
mkdir guifi_dev
cd guifi_dev
git clone https://github.com/agustim/gdk
```
To set up the development environment you need to download the sources:
* Guifi.net module => guifi folder
* Guifi.net budgets module => budgets folder
* Guifi.net 2011 theme => theme_guifinet2011 folder

You can download these sources automatically by running the first_step.sh script:
```
cd gdk
./first_step.sh
```

# Deployment

To deploy the virtual machine with the development environment, go to the guifi_dev folder (or the name you chose) and run:

```
cd gdk
vagrant up
```

The process takes a few minutes. After that, you can start editing the code in your local machine and see the results live at 
```
http://localhost:8280
```
You need save configuration of theme in:
```
http://localhost:8280/ca/admin/build/themes/settings/guifi.net2011
```

If you need to make changes to the guest virtual machine, you can open a terminal via SSH:
```
vagrant ssh
```
You can suspend the virtual machine with:
```
vagrant suspend
```

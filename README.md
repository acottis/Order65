# TODO
* ~~Fix my old path issues~~
* ~~Refactor~~
* ~~Fix EN-GB install~~
* ~~Answer file find and replace variables~~
* ~~Have Puppet install zero touch~~
* ~~Threading enabled~~
* ~~Configurable Hostname and Windows Server Flavour~~
* ~~Removed pressa ny key to enter~~
* ~~Implement Puppet~~
* ~~Complete Web API Work to start the process~~
* Add more puppet roles/Windows roles
* Create config file multi vm creation (like teraform)
* Implement PXE boot option
* Add Korean Language pack to windows
* Add an error firing mechanism from the starting VM for feedback on how build is going and if it fails
* Secret management
* ..

## Overview
1. We modify a WinPE ISO and windows installer ISO using powershell:
    * Change background image
    * Modify Startnet.cmd
    * Modify windows installer first run action
    * Insert unattended.xml
2. Once images are created they sit in a SMB share accessible from our build environment (Should be a private lan)
3. API request with the VM creation information is made by the user to https://github.com/acottis/vm-api
4. This API sends the information to our build hyper-v server and inserts the variables into a config file on a share
5. When the VM is building it will look for its specific config file with the variables to insert into the build using the bios serial number to link a config file with a new vm build. Motiviation for this is to avoid having to modify the image ever build request which would slow down the process considerably
6. Puppet will be install as part of the OS first run after installation and then puppet will take over configuring the server to our specification. For example installing the domain controller role and any other software we want.

## Puppet Process
1. Install Puppet
2. Configure firewalld for 8443/tcp
3. /etc/puppetlabs/code/environments/production/manifests/site.pp node 'default' config for clients
4. Custom certificate policy application specified in puppet.conf, takes one arg and returns 0 cert for good 1 for bad cert
5. Using puppet best practice of roles and profiles https://puppet.com/docs/pe/2019.8/osp/the_roles_and_profiles_method.html 

## Software currently Required
WinPE enviroment bootloader + WinPE Powershell tools
Windows Server 2022 + EN-GB Language Pack

## Software installed on Guest
Puppet-Agent 7.13.1 
Visual Studio Code

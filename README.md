# TODO
* ~~Fix my old path issues~~
* ~~Refactor~~
* ~~Fix EN-GB install~~
* Answer file find and replace variables
* Implement Puppet
* Have Pupper install zero touch
* Implement PXE
* Add Korean Language
* ..
* ..
* 

## Windows Process
1. We mount the PE, change the background and add a modified startnet.cmd
2. 

## Puppet Process
1. Install Puppet
2. Configure firewalld for 8443/tcp
3. /etc/puppetlabs/code/environments/production/manifests/site.pp node 'default' config for clients
4. Custom certificate policy application specified in puppet.conf, takes one arg and returns 0 cert for good 1 for bad cert

## Software currently Required
WinPE enviroment bootloader + WinPE Powershell tools
Windows Server 2022 + EN-GB Language Pack


## Software installed on Guest
Puppet-Agent 7.13.1 

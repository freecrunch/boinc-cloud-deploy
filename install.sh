#!/bin/bash
# boinc-cloud-deploy v0.0.1
# Part of the FreeCrunch project
# https://freecrunch.github.io/

# Setup and read user preferences
install_boinctui="y"
set_rpc_pw="y"

echo "boinc-cloud-deploy v0.0.1"
echo "https://freecrunch.github.io/"
echo "--"

echo "Please supply some credentials to use. These credentials must match the credentials you used to sign up for BAM."
echo "Additionally the email address and password you supply will also be used when signing up for projects."
echo ""
read -p "Enter your username: " username
echo -n "Enter your password: "
read -s password
echo

while true; do
    read -p "Install boinctui terminal GUI? [Y/n]: " yn
    case $yn in
        [Yy]* ) install_boinctui="y"; break;;
        [Nn]* ) install_boinctui="n"; break;;
        * ) echo "Y/N choice required";;
    esac
done

while true; do
    read -p "Set password for RPC access? [Y/n]: " yn
    case $yn in
        [Yy]* ) set_rpc_pw="y"; break;;
        [Nn]* ) set_rpc_pw="n"; break;;
        * ) echo "Y/N choice required";;
    esac
done

echo "Beginning deployment..."

# Upgrade system before deploying everything else
apt-get update
apt-get upgrade

# Install boinc-client
echo "Installing the BOINC client..."
apt-get install boinc-client

# Install boinctui (if required)
if [ $install_boinctui == "y" ]; then
    echo "Installing boinctui terminal GUI..."
    apt-get install boinctui
fi

# Setup GUI RPC access (if required) with the supplied info
if [ $set_rpc_pw == "y" ]; then
    echo "Setting up RPC access and restarting the BOINC service. Remember to open inbound TCP port 31416 on your cloud instance."
    echo $password >> /var/lib/boinc-client/gui_rpc_auth.cfg
    systemctl restart boinc-client.service
    sleep 1
fi

# Attach to BAM with the supplied credentials
echo "Attaching BOINC to BAM..."
boinccmd --acct_mgr attach https://bam.boincstats.com $username $password

# Finished!
echo "Finished!\n"

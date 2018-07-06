#!/bin/bash
# boinc-cloud-deploy v0.0.1
# Part of the FreeCrunch project
;# https://freecrunch.github.io/

# Setup and read user preferences
install_boinctui="y"
set_rpc_pw="y"

echo "boinc-cloud-deploy v0.0.1"
echo "https://freecrunch.github.io/"
echo "--"

echo "Please supply some credentials to use. These credentials must match the"
echo "credentials you used to sign up for BAM."
echo "Additionally the email address and password you supply will also be used"
echo "when signing up for projects and for the BOINC RPC API.."
echo ""
read -p "Enter your username: " username
echo -n "Enter your password: "
read -s password
echo

while true; do
    read -p "Install boinctui terminal GUI? [y/n]: " yn
    case $yn in
        [Yy]* ) install_boinctui="y"; break;;
        [Nn]* ) install_boinctui="n"; break;;
        * ) echo "Y/N choice required";;
    esac
done

while true; do
    read -p "Set password for RPC access? [y/n]: " yn
    case $yn in
        [Yy]* ) set_rpc_pw="y"; break;;
        [Nn]* ) set_rpc_pw="n"; break;;
        * ) echo "Y/N choice required";;
    esac
done

if[ $set_rpc_pw == "y" ]; then
    read -p "Enter the IP address you'll be connecting from: " rpcip
fi

echo "\n------------------------"
echo "Beginning deployment..."


# Upgrade system before deploying everything else
apt-get -y update
apt-get -y upgrade

# Install boinc-client

echo "\n------------------------"
echo "Installing the BOINC client...\n"
apt-get -y install boinc-client

# Install boinctui-extended (if required)
if [ $install_boinctui == "y" ]; then
    echo "\n------------------------"
    echo "Installing boinctui-extended terminal GUI...\n"
    #apt-get install boinctui
    echo "\nDownloading...\n"
    apt-get -y install make autoconf g++ libssl-dev libexpat1-dev libncursesw5-dev
    git clone https://github.com/mpentler/boinctui-extended.git
    cd boinctui-extended
    echo "\nCompiling...\n"
    autoconf
    ./configure --without-gnutls
    make
    make install
fi

# Setup GUI RPC access (if required) with the supplied info
if [ $set_rpc_pw == "y" ]; then
    echo "\n------------------------"
    echo "Setting up RPC access and restarting the BOINC service."
    echo "Remember to open inbound TCP port 31416 on your cloud instance."
    rm -rf /var/lib/boinc-client/gui_rpc_auth.cfg
    touch /var/lib/boinc-client/gui_rpc_auth.cfg
    echo $password >> /var/lib/boinc-client/gui_rpc_auth.cfg
    rm -rf /var/lib/boinc-client/remote_hosts.cfg
    touch /var/lib/boinc-client/remote_hosts.cfg
    echo $rpcip >> /var/lib/boinc-client/remote_hosts.cfg
    systemctl restart boinc-client.service
    sleep 1
fi

# Attach to BAM with the supplied credentials
echo "Attaching BOINC to BAM..."
boinccmd --acct_mgr attach https://bam.boincstats.com $username $password

# Finished!
echo "Finished!\n"

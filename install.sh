#!/bin/bash
# boinc-cloud-deploy v0.0.1
# Part of the FreeCrunch project
# https://freecrunch.github.io/

# Setup and read user preferences
install_boinctui="y"
set_rpc_pw="y"

printf "%s\\n" "-----------------------------"
printf "boinc-cloud-deploy v0.0.1\\n"
printf "https://freecrunch.github.io/\\n"
printf "%s\\n" "-----------------------------"
printf "Please supply some credentials to use. These credentials must match the\\n"
printf "credentials you used to sign up for BAM.\\n"
printf "Additionally the email address and password you supply will also be used\\n"
printf "when signing up for projects and for the BOINC RPC API.\\n\\n"

read -p "Enter your username: " username
printf "Enter your password: "
read -s password
printf "\\n"

while true; do
    read -p "Install boinctui terminal GUI? [y/n]: " yn
    case $yn in
        [Yy]* ) install_boinctui="y"; break;;
        [Nn]* ) install_boinctui="n"; break;;
        * ) printf "Y/N choice required";;
    esac
done

while true; do
    read -p "Set password for RPC access? [y/n]: " yn
    case $yn in
        [Yy]* ) set_rpc_pw="y"; break;;
        [Nn]* ) set_rpc_pw="n"; break;;
        * ) printf "Y/N choice required";;
    esac
done

if [ $set_rpc_pw == "y" ]; then
    read -p "Enter the IP address you'll be connecting from: " rpcip
fi

printf "%s\\n" "-----------------------------"
printf "Beginning deployment..."


# Upgrade system before deploying everything else
apt-get -y update
apt-get -y upgrade

# Install boinc-client

printf "%s\\n" "-----------------------------"
printf "Installing the BOINC client...\\n"
apt-get -y install boinc-client

# Install boinctui-extended (if required)
if [ $install_boinctui == "y" ]; then
    printf "%s\\n" "-----------------------------"
    printf "Installing boinctui-extended terminal GUI...\\n"
    #apt-get install boinctui
    printf "\\nDownloading...\\n"
    apt-get -y install make autoconf g++ libssl-dev libexpat1-dev libncursesw5-dev
    git clone https://github.com/mpentler/boinctui-extended.git
    cd boinctui-extended || exit
    printf "\\nCompiling...\\n"
    autoconf
    ./configure --without-gnutls
    make
    make install
fi

# Setup GUI RPC access (if required) with the supplied info
if [ $set_rpc_pw == "y" ]; then
    printf "%s\\n" "-----------------------------"
    printf "Setting up RPC access and restarting the BOINC service.\\n"
    printf "Remember to open inbound TCP port 31416 on your cloud instance.\\n"
    rm -rf /var/lib/boinc-client/gui_rpc_auth.cfg
    touch /var/lib/boinc-client/gui_rpc_auth.cfg
    echo "$password" >> /var/lib/boinc-client/gui_rpc_auth.cfg
    rm -rf /var/lib/boinc-client/remote_hosts.cfg
    touch /var/lib/boinc-client/remote_hosts.cfg
    echo "$rpcip" >> /var/lib/boinc-client/remote_hosts.cfg
    systemctl restart boinc-client.service
    sleep 1
fi

# Attach to BAM with the supplied credentials
printf "%s\\n" "-----------------------------"
printf "Attaching BOINC to BAM...\\n"
boinccmd --acct_mgr attach https://bam.boincstats.com "$username" "$password"

# Finished!
printf "%s\\n" "-----------------------------"
printf "Finished!\\n"

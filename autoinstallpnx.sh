#!/bin/bash
################################################################################
# Original Author:   Alex Lucas
# Forked from: https://github.com/phantomxdev/phantomx
# Web: http://www.phantomx.org
#
#
# Usage:
#   This script is for auto-compile the PNX wallet taken from github official
#   account & do a fast sync downloading the latest blockchain
#
# Tested on
#   Ubuntu 16.04
#   Raspberry Pi 3 (not tested yet)
#
################################################################################


outputColorGreen() {
    printf "\E[1;32;40m"
    echo "$1"
    printf "\E[0m"
}

outputColorYellow() {
    printf "\E[0;33;40m"
    echo "$1"
    printf "\E[0m"
}

outputColorGreen "============================================================"
outputColorGreen "==================== P H A N T O M   X ====================="
outputColorGreen "============================================================"

sleep 3

###############################################################################
###############################################################################
###############################################################################

outputColorYellow "###########################################################"
outputColorYellow "###              Updating Linux distribution            ###"
outputColorYellow "###########################################################"


sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get dist-upgrade

###############################################################################
###############################################################################
###############################################################################

outputColorYellow "############################################################"
outputColorYellow "### Install all necessary packages for building PhantomX ###"
outputColorYellow "############################################################"

sudo apt-get install -y dnsutils
sudo apt-get install -y build-essential libssl-dev libboost-all-dev git
sudo apt-get install -y libdb5.3++-dev libminiupnpc-dev screen autoconf
sudo apt-get install -y unzip

###############################################################################
###############################################################################
###############################################################################

outputColorYellow "############################################################"
outputColorYellow "###     Creating a Swap File for < 4Gb Ram servers       ###"
outputColorYellow "############################################################"

sudo /bin/dd if=/dev/zero of=/var/swap.1 bs=1M count=2048
sudo /sbin/mkswap /var/swap.1
sudo chmod 600 /var/swap.1
sudo /sbin/swapon /var/swap.1

##Need to autoedit file to add at the boot (Appends this line to that file)
echo "/var/swap.1 swap swap defaults 0 0" >> /etc/fstab

###############################################################################
###############################################################################
###############################################################################


outputColorYellow "#################################################################"
outputColorYellow "# Creating local wallet folder to download and install PhantomX #"
outputColorYellow "#################################################################"

sudo mkdir /wallets
sudo chmod 777 /wallets


###############################################################################
###############################################################################
###############################################################################



outputColorYellow "########################################"
outputColorYellow "# Downloading source code from Github  #"
outputColorYellow "########################################"

cd /wallets
git clone https://github.com/phantomxdev/phantomx.git phantomx


outputColorYellow "####################################"
outputColorYellow "# Compiling Level DB Prerrequisite #"
outputColorYellow "####################################"

cd /wallets/phantomx/src/leveldb
chmod +x build_detect_platform
make libleveldb.a libmemenv.a


outputColorYellow "###################################"
outputColorYellow "# Compiling SECP256 Prerrequisite #"
outputColorYellow "###################################"

cd /wallets/phantomx/src/secp256k1
chmod +x autogen.sh
./autogen.sh
./configure
make


outputColorYellow "########################################"
outputColorYellow "# Compiling PNX WALLET (TAKES A WHILE) #"
outputColorYellow "########################################"

cd /wallets/phantomx/src
sudo make -f makefile.unix

outputColorYellow "##################################"
outputColorYellow "# Configuring latest parameters  #"
outputColorYellow "##################################"

echo "Creating database folder"
cd /wallets
cp /wallets/phantomx/src/phantomxd /wallets/phantomx/
mkdir /wallets/phantomx/wallet

echo "Creating phantomx.conf file"
echo "rpcallowip=127.0.0.1" >> /wallets/phantomx/wallet/phantomx.conf
echo "rpcuser=user" >> /wallets/phantomx/wallet/phantomx.conf
echo "rpcpassword=password" >> /wallets/phantomx/wallet/phantomx.conf
echo "listen=1" >> /wallets/phantomx/wallet/phantomx.conf
echo "server=1" >> /wallets/phantomx/wallet/phantomx.conf
echo "addnode=54.218.118.59:9340" >> /wallets/phantomx/wallet/phantomx.conf
echo "addnode=54.218.118.59:9341" >> /wallets/phantomx/wallet/phantomx.conf


###############################################################################
###############################################################################
###############################################################################

outputColorYellow "########################################"
outputColorYellow "#   Downloading the latest blockchain  #"
outputColorYellow "########################################"

echo "Getting latest blockchain from official site"
cd /wallets/
wget http://phantomx.co/download/latest-blockchain.zip

echo "Extrating files..."
sudo unzip /wallets/latest-blockchain.zip

echo "Copying files"
sudo cp -R /wallets/wallets/latest-blockchain/database /wallets/phantomx/wallet
sudo cp -R /wallets/wallets/latest-blockchain/txleveldb /wallets/phantomx/wallet
sudo cp  /wallets/wallets/latest-blockchain/peers.dat /wallets/phantomx/wallet/peers.dat
sudo cp  /wallets/wallets/latest-blockchain/blk0001.dat /wallets/phantomx/wallet/blk0001.dat

echo "Removing temp files"
sudo rm -r /wallets/latest-blockchain.zip
sudo rm -r /wallets/wallets

outputColorGreen "################################################################"
outputColorGreen "#                                                              #"
outputColorGreen "#                          ALL DONE                            #"
outputColorGreen "#                                                              #"
outputColorGreen "#  Compiled Phantomx file path: /wallets/phantomx/phantomxd    #"
outputColorGreen "#  PhantomX database dir: /wallets/phantomx/wallet             #"
outputColorGreen "#  PNX Conf file path: /wallets/phantomx/wallet/phantomx.conf  #"
outputColorGreen "#                                                              #"
outputColorGreen "#   To run pnx wallet run the following command:               #"
outputColorGreen "#                                                              #"
outputColorGreen "#   /wallets/phantomx/phantomxd                                #"
outputColorGreen "#     -datadir=/wallets/phantomx/wallet -daemon -start         #"
outputColorGreen "#                                                              #"
outputColorGreen "################################################################"
outputColorGreen "#                            Infos                             #"
outputColorGreen "################################################################"
outputColorGreen "#                                                              #"
outputColorGreen "# Visit our website: http://www.phantomx.co                    #"
outputColorGreen "# Check guides how to create masternodes & news about PhantomX #"
outputColorGreen "#                                                              #"
outputColorGreen "################################################################"

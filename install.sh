#!/bin/bash

# Install OpenAI Spinning Up on Ubuntu 22.04

# Install dependencies
# https://spinningup.openai.com/en/latest/user/installation.html#installing-openmpi
# https://ubuntu.com/tutorials/ubuntu-desktop-aws#2-setting-up-tightvnc-on-aws
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y \
     libopenmpi-dev \
     ubuntu-desktop \
     emacs-nox
sudo apt-get clean -y

# Disable default GUI start up
# https://linuxconfig.org/how-to-disable-enable-gui-in-ubuntu-22-04-jammy-jellyfish-linux-desktop
sudo systemctl set-default multi-user

# Install NoMachine
# https://downloads.nomachine.com/download/?id=1
# https://kb.nomachine.com/AR06T01163
wget https://download.nomachine.com/download/8.11/Linux/nomachine_8.11.3_4_amd64.deb
sudo dpkg -i nomachine_8.11.3_4_amd64.deb
mkdir -p ~/.nx/config
cp -p  ~/.ssh/authorized_keys  ~/.nx/config/authorized.crt
OLD="/usr/bin/dbus-run-session gnome-session --session=ubuntu"
NEW="gnome-session --session=ubuntu"
sudo cp /usr/NX/etc/node.cfg /usr/NX/etc/node.cfg.orig
sudo cat /usr/NX/etc/node.cfg.orig | sed "s%$OLD%$NEW%" > /usr/NX/etc/node.cfg

# Install Miniconda
# https://docs.anaconda.com/free/anaconda/install/silent-mode/
# https://spinningup.openai.com/en/latest/user/installation.html#installing-python
# https://stackoverflow.com/questions/72540359/glibcxx-3-4-30-not-found-for-librosa-in-conda-virtual-environment-after-tryin
# https://anaconda.org/conda-forge/gcc
curl https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o ~/miniconda.sh
bash ~/miniconda.sh -b -p $HOME/miniconda
eval "$(/$HOME/miniconda/bin/conda shell.bash hook)"
conda init
conda config --set auto_activate_base false
conda create -n spinningup python=3.6
conda activate spinningup
conda install -c conda-forge gcc=13.2.0

# Setup Spinning up
# https://spinningup.openai.com/en/latest/user/installation.html#installing-spinning-up
git clone https://github.com/ralatsdc/spinningup.git
cd spinningup
git checkout rl/pin-opencv-python
pip install -e .

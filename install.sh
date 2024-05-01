#!/bin/bash

# Install OpenAI Spinning Up on an AWS EC2 Ubuntu 22.04
# instance. Include NoMachine for remote access.

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
curl https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o ~/miniconda.sh
bash ~/miniconda.sh -b -p $HOME/miniconda
eval "$(/$HOME/miniconda/bin/conda shell.bash hook)"
conda init
conda config --set auto_activate_base false
conda create -n spinningup python=3.6 -y
conda activate spinningup

# Setup Spinning up
# https://spinningup.openai.com/en/latest/user/installation.html#installing-spinning-up
# https://stackoverflow.com/questions/72540359/glibcxx-3-4-30-not-found-for-librosa-in-conda-virtual-environment-after-tryin
# https://anaconda.org/conda-forge/gcc
git clone https://github.com/ralatsdc/spinningup.git
cd spinningup
git checkout rl/pin-opencv-python
pip install -e .
conda install -c conda-forge gcc=13.2.0 -y

# Check install
echo <<EOF
To see if you’ve successfully installed Spinning Up, try running PPO
in the LunarLander-v2 environment with

$ python -m spinup.run ppo --hid "[32,32]" --env LunarLander-v2 --exp_name installtest --gamma 0.999

This might run for around 10 minutes, and you can leave it going in
the background while you continue reading through documentation. This
won’t train the agent to completion, but will run it for long enough
that you can see some learning progress when the results come in.

After it finishes training, watch a video of the trained policy with

$ python -m spinup.run test_policy data/installtest/installtest_s0

And plot the results with

$ python -m spinup.run plot data/installtest/installtest_s0
EOF

#!/usr/bin/env bash
# Created by sodingli

set -e

COLOR_NONE='\033[0m'
COLOR_INFO='\033[0;36m'
COLOR_ERROR='\033[1;31m'
COLOR_IMPORTANT='\033[4;31m'

sudo apt-get update
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
sudo apt-add-repository 'deb https://apt.dockerproject.org/repo ubuntu-xenial main'
sudo apt-get update
apt-cache policy docker-engine
sudo apt-get install -y docker-engine

# sudo systemctl status docker
sudo usermod -aG docker ubuntu

echo  "${COLOR_ERROR}You need to ${COLOR_IMPORTANT}logout${COLOR_ERROR} first to run docker without typing ${COLOR_INFO}\`sudo\`${COLOR_NONE}"

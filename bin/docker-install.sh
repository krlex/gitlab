#!/bin/env bash

export DEBIAN_FRONTEND=noninteractive
export GITLAB_HOME=$HOME/gitlab
sudo ufw allow 80
sudo ufw allow 443 
sudo ufw enable 
sudo curl -L --output /usr/local/bin/gitlab-runner "https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64"
sudo chmod +x /usr/local/bin/gitlab-runner
bash <(curl -sL https://raw.githubusercontent.com/krlex/docker-installation/master/install.sh)

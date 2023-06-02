#!/bin/sh

sudo gitlab-ctl stop
sudo gitlab-ctl remove-accounts
sudo gitlab-ctl cleanse
sudo systemctl stop gitlab-runsvdir
sudo systemctl disable gitlab-runsvdir
sudo remove /usr/lib/systemd/system/gitlab-runsvdir.service
sudo systemctl daemon-reload
sudo gitlab-ctl uninstall
sudo apt remove gitlab-ce
sudo rm -rf /etc/gitlab
sudo rm -rf /opt/gitlab*
sudo rm -rf /var/opt/gitlab*
sudo rm -rf /var/log/gitlab*

echo "PLEASE REBOOT YOUR SYSTEM"

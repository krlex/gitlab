#!/usr/bin/env bash

DOMAIN=gitlab.example.com


install_debian() {
  $SUDO apt update
  $SUDO apt install -y apt-transport-https ca-certificates curl perl
  $SUDO apt install -y postfix

  curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.deb.sh | sudo bash

  $SUDO EXTERNAL_URL="https://$DOMAIN" apt-get install gitlab-ee
}

install_ubuntu() {
  $SUDO apt update
  $SUDO apt-get install -y curl openssh-server ca-certificates tzdata perl
  $SUDO apt-get install -y postfix

  curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.deb.sh | sudo bash

  $SUDO EXTERNAL_URL="https://$DOMAIN" apt-get install gitlab-ee

}

install_fedora() {
  $SUDO dnf update -y
  $SUDO dnf install -y curl policycoreutils openssh-server perl
  $SUDO systemctl enable sshd
  $SUDO systemctl start sshd
  # Check if opening the firewall is needed with: sudo systemctl status firewalld
  $SUDO firewall-cmd --permanent --add-service=http
  $SUDO firewall-cmd --permanent --add-service=https
  $SUDO systemctl reload firewalld

  $SUDO dnf install postfix
  $SUDO systemctl enable postfix
  $SUDO systemctl start postfix

  curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.rpm.sh | sudo bash

  $SUDO EXTERNAL_URL="https://$DOMAIN" dnf install gitlab-ee

}

install_centos() {
  $SUDO yum update -y
  $SUDO yum install -y curl policycoreutils openssh-server perl
  $SUDO systemctl enable sshd
  $SUDO systemctl start sshd
  # Check if opening the firewall is needed with: sudo systemctl status firewalld
  $SUDO firewall-cmd --permanent --add-service=http
  $SUDO firewall-cmd --permanent --add-service=https
  $SUDO systemctl reload firewalld

  $SUDO yum  install -y postfix
  $SUDO systemctl enable postfix
  $SUDO systemctl start postfix

  curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.rpm.sh | sudo bash

  $SUDO EXTERNAL_URL="https://$DOMAIN" yum install -y gitlab-ee
}

usage() {
  echo
  echo "Linux distribution not detected"
  echo "Use: ID=[ubuntu|debian|centos|fedora]"
  echo "Other distribution not yet supported"
  echo

}

if [ -f /etc/os-release ]; then
  . /etc/os-release
elif [ -f /etc/debian_version ]; then
  $ID=debian
fi

if [[ $EUID -ne 0 ]]; then
  SUDO='sudo -H'
else
  SUDO=''
fi

case $ID in
        'ubuntu')
                install_ubuntu
        ;;
        'debian')
                install_debian
        ;;
        'centos')
                install_centos
        ;;
        'fedora')
                install_fedora
        ;;
        *)
          usage
        ;;
esac

#!/usr/bin/env bash

echo "Welcome to the GitLab installation script!"
echo "Create .env or see example from env.example"
echo "Please select the edition you want to install:"
echo "1. GitLab Community Edition (gitlab-ce)"
echo "2. GitLab Enterprise Edition (gitlab-ee)"
read -p "Enter your choice (1/2): " choice

if [ -f .env ]; then
  export $(cat .env | grep -v '^#' | xargs)
fi

gitlab-ee_set(){
  curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.deb.sh | sudo bash
}

gitlab-ce_set(){
  curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash
}

if [ $choice -eq 1 ]; then
    echo "Installing GitLab Community Edition..."
    gitlab-ce_set
    echo "Installing packages and Gitlab-ce"
    packages
    $SUDO EXTERNAL_URL="https://$HOSTNAME" apt-get install -y gitlab-ce

elif [ $choice -eq 2 ]; then
    echo "Installing GitLab Enterprise Edition..."
    gitlab-ee_set
    echo "Installing packages and Gitlab-ee"
    packages
    $SUDO EXTERNAL_URL="https://$HOSTNAME" apt-get install -y gitlab-ee
else
    echo "Invalid choice. Exiting."
fi

packages() {
  install_fedora
  install_ubuntu
  install_debian
  install_centos
}

install_debian() {
  $SUDO apt update
  $SUDO apt install -y apt-transport-https ca-certificates curl perl
  $SUDO apt install -y postfix
}

install_ubuntu() {
  $SUDO apt update
  $SUDO apt-get install -y curl openssh-server ca-certificates tzdata perl
  $SUDO apt-get install -y postfix

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

#!/usr/bin/env bash

echo "Welcome to the GitLab installation script!"
echo "Create .env or see example from env.example"
echo "Please select the edition you want to install:"
echo "1. GitLab Community Edition (gitlab-ce)"
echo "2. GitLab Enterprise Edition (gitlab-ee)"
read -p "Enter your choice (1/2): " choice

#if [ -f .env ]; then
#  export $(cat .env | grep -v '^#' | xargs)
#fi

set_env() {
  if [ ! -f .env ]; then
      echo ".env is not found!"
      exit 1
  fi
  
  HOSTNAME=$(grep -w "HOSTNAME" .env | cut -d '=' -f2)
  
  if [ -z "$HOSTNAME" ]; then
      echo "HOSTNAME not found in .env file!"
      exit 1
  fi
  
  GITLAB_CONFIG="/etc/gitlab/gitlab.rb"
  
  if [ ! -f "$GITLAB_CONFIG" ]; then
      echo "gitlab.rb file is not found!"
      exit 1
  fi
  
  sudo sed -i "s|^external_url .*|external_url 'http://$HOSTNAME'|" "$GITLAB_CONFIG"
  sudo gitlab-ctl reconfigure
  
  echo "EXTERNAL_URL u gitlab.rb is success updated on http://$HOSTNAME"
}

gitlab-ee_set(){
  curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.deb.sh | sudo bash
}

gitlab-ce_set(){
  curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash
}

if [[ $EUID -ne 0 ]]; then
  SUDO='sudo -H'
else
  SUDO=''
fi

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
install_ubuntu() {
  $SUDO apt update
  $SUDO apt-get install -y curl openssh-server ca-certificates tzdata perl
  $SUDO apt-get install -y postfix
}
install_debian() {
  $SUDO apt update
  $SUDO apt install -y apt-transport-https ca-certificates curl perl
  $SUDO apt install -y postfix
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

install_packages() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        
        if [[ "$ID" == "ubuntu" || "$ID" == "debian" ]]; then
            echo "Debian/Ubuntu is recognized."
            install_ubuntu 
        
        elif [[ "$ID" == "centos" || "$ID" == "rhel" ]]; then
            echo "CentOS/RHEL is recognized."
            install_centos
        
        elif [[ "$ID" == "fedora" ]]; then
            echo "Fedora is recognized."
            install_fedora
        
        else
            echo "This Linux system is not recognized: $ID"
            exit 1
        fi
    else
        echo "We can no recognize this system"
        exit 1
    fi
}

usage() {
  echo
  echo "Linux distribution not detected"
  echo "Use: ID=[ubuntu|debian|centos|fedora]"
  echo "Other distribution not yet supported"
  echo
}


if [ $choice -eq 1 ]; then
    echo "Installing GitLab Community Edition..."
    gitlab-ce_set
    echo "Installing packages and Gitlab-ce"
    #$SUDO export EXTERNAL_URL="https://$HOSTNAME" 
    install_packages
    $SUDO apt install -y gitlab-ce
    set_env

elif [ $choice -eq 2 ]; then
    echo "Installing GitLab Enterprise Edition..."
    gitlab-ee_set
    echo "Installing packages and Gitlab-ee"
    #$SUDO export EXTERNAL_URL="https://$HOSTNAME"
    install_packages
    $SUDO apt install -y gitlab-ee
    set_env
else
    echo "Invalid choice. Exiting."
fi

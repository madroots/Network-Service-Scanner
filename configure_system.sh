#!/bin/bash
clear

# Ask for sudo
sudo ls
clear
read -s -p "Some operations require root privileges. Enter your password: " sudo_password
echo

# Function to execute commands with sudo and echo the command
run_command() {
    echo $sudo_password | sudo -S sh -c "$1"
    echo "Executed: $1"
}

# Disable unwanted locales
run_command "sh -c 'echo \"\" > /etc/locale.gen'"
run_command "sh -c 'echo \"en_US.UTF-8 UTF-8\" >> /etc/locale.gen'"
echo "Unwanted locales disabled."

# Set DEBIAN_FRONTEND variable to noninteractive
run_command "export DEBIAN_FRONTEND=noninteractive"

# Update system and install packages
run_command "apt update"
run_command "echo grub-pc grub-pc/install_devices multiselect | sudo debconf-set-selections"
run_command "apt -y -o Dpkg::Options::=\"--force-confnew\" upgrade"
run_command "apt install chromium openssh-server fonts-noto-color-emoji feh -y"

# Enable SSH
run_command "update-rc.d ssh enable"
run_command "service ssh start"
echo "SSH enabled and started."

# Change boot wait time
run_command "sed -i 's/GRUB_TIMEOUT=.*/GRUB_TIMEOUT=1/' /etc/default/grub"
run_command "update-grub"
echo "GRUB timeout changed to 1 seconds."

# Download Shooter app
app_url="http://192.168.4.177:50050/ShooterDeploy_20230609_2.tar.gz"
wget -P ~/Documents $app_url
app_file_name=$(basename $app_url)
echo "Downloading and extracting Shooter app..."
tar -xvf ~/Documents/$app_file_name -C ~/Documents/

# Copy SSH public key to remote system
ssh_public_key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCA2y9YWYn0ZJoijzUGEDMFDximB1jLCHTIYunvNV8U06kPV8xOOsBdv+Mco8RpBaAvERELQ2FLHqeN+HKoAdQGG1f49i9F5Jl7UdkJIvhKNPl6IA18VLmvrRbWgghqAWzyXrwKz"
echo "Copying SSH public key to the remote system..."
run_command "mkdir -p ~/.ssh && echo '$ssh_public_key' >> ~/.ssh/authorized_keys && chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys"

# Open ports with ufw
run_command "ufw allow 12000/tcp"
run_command "ufw allow 12001/tcp"
run_command "ufw allow 13000/tcp"
run_command "ufw allow 13001/tcp"
run_command "ufw allow 12002/tcp"
run_command "ufw enable"
run_command "ufw start"

# Reboot
echo "Rebooting the remote system..."
run_command "reboot"

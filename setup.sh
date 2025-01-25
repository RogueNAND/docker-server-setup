#! /bin/bash
set -e
clear

GREEN="\e[32m"
ENDCOLOR="\e[0m"
REPO="roguenand/docker-server-setup"
USERNAME="fleetuser"
CUR_TIMEZONE=$(timedatectl show | grep zone | sed 's/Timezone=//g');
NPM_DB_PASSWORD=$(< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c"${1:-20}" | sed 's/-/_/g')


# intro message
echo -e "${GREEN}This script should be run as the root user on a new Debian or Ubuntu server.${ENDCOLOR}"

# change timezone (works on debian / ubuntu / fedora)
read -r -p "$(echo -e "The system time zone is ${GREEN}$CUR_TIMEZONE${ENDCOLOR}. Do you want to change it (y/n)?${ENDCOLOR}")" yn
if [[ $yn =~ ^[Yy]$ ]]; then
  if command -v dpkg-reconfigure &> /dev/null; then
    dpkg-reconfigure tzdata;
  else
    read -r -p "Enter time zone: " new_timezone;
    if timedatectl set-timezone "$new_timezone"; then
      echo -e "${GREEN}Time zone has changed to: $new_timezone ${ENDCOLOR}"
    else
      echo -e "Run ${GREEN}timedatectl list-timezones${ENDCOLOR} to view all time zones";
      exit;
    fi
  fi
fi

# create user account (works on debian / ubuntu / fedora)
echo -e "${GREEN}Create new user for docker containers '$USERNAME'${ENDCOLOR}"
id -u somename &>/dev/null || /sbin/useradd -m -s /bin/bash "$USERNAME"
passwd "$USERNAME"
/sbin/usermod -aG sudo "$USERNAME" || usermod -aG wheel "$USERNAME"


echo -e "${GREEN}Update system & packages${ENDCOLOR}"
apt update && apt upgrade -y


echo -e "${GREEN}Configure automatic updates${ENDCOLOR}"
apt install git unattended-upgrades -y
dpkg-reconfigure --priority=low unattended-upgrades


# clone repo and copy files
git clone --depth=1 "https://github.com/$REPO.git" /tmp/docker-server


echo -e "${GREEN}Setup docker${ENDCOLOR}"
source /tmp/docker-server/res/docker.sh


echo -e "${GREEN}GitHub SSH key synchronization${ENDCOLOR}"
source /tmp/docker-server/res/ssh.sh


echo -e "${GREEN}Network setup${ENDCOLOR}"
source /tmp/docker-server/res/network.sh


# aliases / .bashrc stuff
{
  echo 'alias dcu="docker compose up -d"';
  echo 'alias dcd="docker compose down"';
  echo 'alias dcr="docker compose restart"';
  echo 'alias ctop="docker run --rm -ti --name=ctop --volume /var/run/docker.sock:/var/run/docker.sock:ro quay.io/vektorlab/ctop:latest"';
} >> /home/"$USERNAME"/.bashrc


rm -r /tmp/docker-server ||:
rm ./setup.sh
echo -e "${GREEN}Setup complete 👍. Restart required for SSH keys and network configuration to take effect. Login using '$USERNAME' and your defined password ${ENDCOLOR}"


# option to reboot
read -r -p "$(echo -e "${GREEN}Reboot now (y/n)?${ENDCOLOR}")" yn
if [[ $yn =~ ^[Yy]$ ]]; then
  reboot;
fi

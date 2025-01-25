wget -q -O /tmp/get-docker.sh https://get.docker.com
sh /tmp/get-docker.sh

# clone repo and copy files
mkdir -p "/home/$USERNAME/server"
cp /tmp/docker-server/docker-compose.yml "/home/$USERNAME/server/docker-compose.yml"

# replace docker compose variables
#sed -i "s|USER_TIMEZONE|$(timedatectl show | grep zone | sed 's/Timezone=//g')|" "/home/$USERNAME/server/docker-compose.yml"
docker compose -f "/home/$USERNAME/server/docker-compose.yml" up -d

# add user to docker users
usermod -aG docker "$USERNAME"


#!/bin/bash
export HOME=$LSDC2_HOME

# Download Terraria dedicated server
TERRARIA_VERSION=${TERRARIA_VERSION:-1.4.4.9}
version_short=${TERRARIA_VERSION//.}
version_url=https://terraria.org/api/download/pc-dedicated-server/terraria-server-${version_short}.zip

curl -s -L $version_url -o terraria.zip
unzip terraria.zip
rm terraria.zip

terraria_bin=./${version_short}/Linux/TerrariaServer.bin.x86_64

# Create the configuration file
case "$WORLD_SIZE" in
    small) WORLD_SIZE=1;;
    medium) WORLD_SIZE=2;;
    large) WORLD_SIZE=3;;
    *) WORLD_SIZE=2;;
esac

case "$WORLD_DIFFICULTY" in
    normal|0) WORLD_DIFFICULTY=0;;
    expert|1) WORLD_DIFFICULTY=1;;
    master|2) WORLD_DIFFICULTY=2;;
    journey|3) WORLD_DIFFICULTY=3;;
    *) WORLD_DIFFICULTY=0;;
esac

cat > $LSDC2_HOME/config <<EOF
world=$GAME_SAVEDIR/$GAME_SAVENAME.wld
autocreate=$WORLD_SIZE
seed=$WORLD_SEED
worldname=$GAME_SAVENAME
difficulty=$WORLD_DIFFICULTY
port=$GAME_PORT
password=$SERVER_PASS
motd=Welcome to the Terraria des copains !
worldpath=$GAME_SAVEDIR
secure=1
upnp=0
npcstream=60
priority=1 
EOF


# The trap send the "exit" command to the server to trigger a world save
mkfifo /tmp/trapfifo

shutdown() {
     echo "exit" > /tmp/trapfifo
}

trap shutdown SIGINT SIGTERM


chmod +x $terraria_bin
$terraria_bin -config $LSDC2_HOME/config < /tmp/trapfifo &
pid=$!

# This is needed for some reason
echo "" > /tmp/trapfifo

wait $pid

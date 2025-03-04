#!/bin/bash
export HOME=$TERRARIA_HOME

# Download Terraria dedicated server
TERRARIA_VERSION=${TERRARIA_VERSION:-1.4.4.9}
VERSION_SHORT=${TERRARIA_VERSION//.}
VERSION_URL=https://terraria.org/api/download/pc-dedicated-server/terraria-server-${VERSION_SHORT}.zip

curl -s -L $VERSION_URL -o terraria.zip
unzip terraria.zip
rm terraria.zip

TERRARIA_BIN=./${VERSION_SHORT}/Linux/TerrariaServer.bin.x86_64

# Create the configuration file
case "$WORLD_SIZE" in
    small) WORLD_SIZE=1;;
    medium) WORLD_SIZE=2;;
    large) WORLD_SIZE=3;;
    *) WORLD_SIZE=2;;
esac

case "$WORLD_DIFFICULTY" in
    normal) WORLD_DIFFICULTY=0;;
    expert) WORLD_DIFFICULTY=1;;
    master) WORLD_DIFFICULTY=2;;
    journey) WORLD_DIFFICULTY=3;;
    *) WORLD_DIFFICULTY=0;;
esac

cat > $TERRARIA_HOME/config <<EOF
world=$WORLD_PATH/$WORLD_NAME.wld
autocreate=$WORLD_SIZE
seed=$WORLD_SEED
worldname=$WORLD_NAME
difficulty=$WORLD_DIFFICULTY
port=$SERVER_PORT
password=$SERVER_PASS
motd=Welcome to Terraria !
worldpath=$WORLD_PATH
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


chmod +x $TERRARIA_BIN
$TERRARIA_BIN -config $TERRARIA_HOME/config < /tmp/trapfifo &
pid=$!

# This is needed for some reason
echo "" > /tmp/trapfifo

wait $pid

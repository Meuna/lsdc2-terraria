FROM docker.io/ubuntu:22.04

ENV TERRARIA_HOME=/terraria

ENV WORLD_PATH=$TERRARIA_HOME/worlds \
    WORLD_NAME=lsdc2 \
    WORLD_SIZE=medium \
    WORLD_DIFFICULTY=normal \
    WORLD_SEED= \
    SERVER_PORT=7777 \
    SERVER_PASS=terraria

ENV LSDC2_SNIFF_IFACE="eth0" \
    LSDC2_SNIFF_FILTER="tcp port $SERVER_PORT" \
    LSDC2_CWD=$TERRARIA_HOME \
    LSDC2_UID=1000 \
    LSDC2_GID=1000 \
    LSDC2_PERSIST_FILES="$WORLD_NAME.wld" \
    LSDC2_ZIP=1 \
    LSDC2_ZIPFROM=$WORLD_PATH

WORKDIR $TERRARIA_HOME

ADD https://github.com/Meuna/lsdc2-serverwrap/releases/download/v0.2.0/serverwrap /serverwrap

COPY start-server.sh $TERRARIA_HOME
RUN apt-get update && apt-get install -y curl unzip \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd -g $LSDC2_GID -o terraria \
    && useradd -g $LSDC2_GID -u $LSDC2_UID -d $TERRARIA_HOME -o --no-create-home terraria \
    && mkdir $WORLD_PATH \
    && chmod u+x /serverwrap start-server.sh \
    && chown -R terraria:terraria $TERRARIA_HOME

EXPOSE 7777/tcp
ENTRYPOINT ["/serverwrap"]
CMD ["./start-server.sh"]

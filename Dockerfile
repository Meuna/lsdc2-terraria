FROM docker.io/ubuntu:22.04

ENV LSDC2_USER=lsdc2 \
    LSDC2_HOME=/lsdc2 \
    LSDC2_UID=2000 \
    LSDC2_GID=2000

WORKDIR $LSDC2_HOME

ADD https://github.com/Meuna/lsdc2-serverwrap/releases/download/v0.4.2/serverwrap /usr/local/bin
COPY start-server.sh $LSDC2_HOME
RUN apt-get update && apt-get install -y curl unzip \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd -g $LSDC2_GID -o $LSDC2_USER \
    && useradd -g $LSDC2_GID -u $LSDC2_UID -d $LSDC2_HOME -o --no-create-home $LSDC2_USER \
    && chmod +x /usr/local/bin/serverwrap start-server.sh \
    && chown -R $LSDC2_USER:$LSDC2_USER $LSDC2_HOME

ENV GAME_SAVEDIR=$LSDC2_HOME/savedir \
    GAME_SAVENAME=lsdc2 \
    GAME_PORT=7777

ENV LSDC2_SNIFF_IFACE="eth1" \
    LSDC2_SNIFF_FILTER="tcp port $GAME_PORT" \
    LSDC2_PERSIST_FILES="$GAME_SAVENAME.wld" \
    LSDC2_ZIPFROM=$GAME_SAVEDIR

ENTRYPOINT ["serverwrap"]
CMD ["./start-server.sh"]

FROM alpine:3.12.0

# Workdir
WORKDIR /data

# Installation des pré-requis
RUN apk --update --no-cache add ffmpeg youtube-dl

# Copie des sources
COPY ./src/gong /usr/local/bin/gong
RUN chmod +x /usr/local/bin/gong

# Commande exécutée par défaut
ENTRYPOINT [ "gong" ]
CMD [ "/data/hostages", "/data/survivors" ]


# udev
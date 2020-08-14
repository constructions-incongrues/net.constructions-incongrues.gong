FROM alpine:3.12.0

# Installation des pré-requis
RUN apk --update --no-cache add youtube-dl

# Entrypoint
ENTRYPOINT [ "youtube-dl" ]

# udev
# https://hub.docker.com/_/nginx
FROM nginx:stable-alpine

# Copie des sources de l'application
COPY ./etc/default.conf /etc/nginx/conf.d/default.conf
COPY ./src /usr/share/nginx/html

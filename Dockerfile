# FROM busybox
FROM alpine:3.7
RUN apk update
RUN apk upgrade
RUN apk add bash

RUN mkdir /app
ADD /monitor /app
WORKDIR /app

CMD ["/bin/sh", "./init.sh"]
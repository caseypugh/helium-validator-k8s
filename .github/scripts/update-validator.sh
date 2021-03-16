#/!bin/bash

source ~/.bash_profiles

QUAY_URL='https://quay.io/api/v1/repository/team-helium/validator/tag/?limit=20&page=1&onlyActiveTags=true'
running_image=$(docker container inspect -f '{{.Config.Image}}' "validator" | awk -F: '{print $2}')

docker run -d \
      --restart always \
      --publish 2154:2154/tcp \
      --name validator \
      --mount type=bind,source=$DATA_PATH,target=/var/data \
      quay.io/team-helium/validator:latest-val-amd64

#!/bin/bash

# Setup env vars
DATA_PATH=$VOLUME_PATH/$($VALIDATOR_NAME)_data

echo "export WORKSPACE=$GITHUB_WORKSPACE" > tmp
echo "export VOLUME_PATH=$VOLUME_PATH" > tmp
echo "export VALIDATOR_NAME=$VALIDATOR_NAME" > tmp
echo "export DATA_PATH=$DATA_PATH" > tmp

rm ~/.bash_profiles
mv tmp ~/.bash_profiles

cd $GITHUB_WORKSPACE

# Update validater miner image
.github/scripts/update-validator.sh

# crontab cron

# Get/save swarm key
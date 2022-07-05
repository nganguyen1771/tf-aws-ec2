#!/bin/bash
rm -rf docker && git clone https://github.com/mattermost/docker
cd docker
cp env.example .env

sed -i '/MATTERMOST_IMAGE_TAG=/ c\MATTERMOST_IMAGE_TAG=7.0.1' .env
sed -i '/MATTERMOST_IMAGE=/ c\MATTERMOST_IMAGE=mattermost-team-edition' .env
mkdir -p ./volumes/app/mattermost/config
mkdir -p ./volumes/app/mattermost/data
mkdir -p ./volumes/app/mattermost/logs
mkdir -p ./volumes/app/mattermost/plugins
mkdir -p ./volumes/app/mattermost/client
mkdir -p ./volumes/app/mattermost/client/plugins
mkdir -p ./volumes/app/mattermost/bleve-indexes
chown -R 2000:2000 ./volumes/app/mattermost && docker-compose -f docker-compose.yml -f docker-compose.without-nginx.yml up -d

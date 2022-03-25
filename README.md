# zenn_preview
create and manage docker container for zenn preview

## configure

modify some of the configurations in Makefile.

REPO=hnakayam/zenn_preview
VERSION=0.1

This is docker image name and tag often used for Docker HUB

ZENN_BASEDIR=/home/zenn-user/zenn-content

This is the absolue path of zenn content directory of user "zenn-user"

## build docker image

$ make build

## run docker image in local environment (in background)

$ make run

## stop running docker image

$ make stop

## upload docker image to Docker HUB

$ make push 

## references

Dockerfile is based of below zenn article.

Zenn CLIのDockerfileとその使い方の紹介
https://zenn.dev/tiryoh/articles/2020-09-24-docker-zenn-cli

## limitations
at this point. you can only use http connection. https connection is not yet supported.

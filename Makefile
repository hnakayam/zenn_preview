# note: build docker image using Ubuntu 18.04 or newer
# requires docker engine and required components
# see https://docs.docker.com/engine/install/ubuntu/

# replace REPO for your docker HUB image path or equivalents
# modify VERSION string to build new image
# see https://hub.docker.com/r/hnakayam/zenn_preview
REPO=hnakayam/zenn_preview
VERSION=0.1

# configure zenn content directory to mount (absolute path) must be exist (use "make testdir" for check)
ZENN_BASEDIR=/home/zenn-user/zenn-content

# provide Zenn CLI ommand
# you can override by "make run ZENN_COMMAND=new:article" etc
#ZENN_COMMAND="preview --port 80"
ZENN_COMMAND=

#
# build docker image
#

# testing Common Name for self signed certificate
#BUILD_CERT_CN=--build-arg cert_cn=apprtc.japaneast.azurecontainer.io

build:
	@if docker image ls "$(REPO):$(VERSION)" | grep "$(REPO)" ; then echo "image already exist." ; else \
		docker build -t "$(REPO):$(VERSION)" $(BUILD_SERVER_IP) $(BUILD_SERVER_PORT) $(BUILD_CERT_CN) . \
	; fi


# "docker image ls" will not set result code so use grep to get result code
ls:
	@if docker image ls "$(REPO):$(VERSION)" | grep "$(REPO)" ; then echo "image exist." ; else echo "image not exist." ; fi

# remove docker image. consider using -f flag like "make rm IMAGE_RM_FLAG=-f"
#IMAGE_RM_FLAG=-f
IMAGE_RM_FLAG=
rm:
	@docker image rm $(IMAGE_RM_FLAG) "$(REPO):$(VERSION)"

# docker push requres "docker login" beforhand. use docker hub account and password.
push:
	docker login && docker push "$(REPO):$(VERSION)"

#
# run docker image
#

# containername for run/stop/attach/check
# you can use any name you like
CONTAINERNAME=my_zenn_preview

# if we didn't cache docker image locally, download specified image from docker hub

# default network mode = bridge when --network option not specified in "docker run" command.

# remove container record created ("--rm", not "-rm")
# detach and run in background (-d)
# use uid:gid for creating files (-u)
# use host port 80 : docker port 80
# no interactive mode and no terminal attach (no "-it")
# optionally you can override DOCKER_RUN_SUDO and ZENN_COMMAND like "make run DOCKER_RUN_SUDO= ZENN_COMMAND=new:article"
# if you use "-it" (interactive shell) option, you can detach shell by pressing Ctrl-P Ctrl-Q
DOCKER_RUN_SUDO=sudo
DOCKER_RUN_OPTION=--rm
run:
	@if ! docker ps | grep -q "$(CONTAINERNAME)" ; then \
		$(DOCKER_RUN_SUDO) docker run --name="$(CONTAINERNAME)" \
		$(DOCKER_RUN_OPTION) \
		-d \
		-u $(id -u):$(id -g) \
		-p 80:80 \
		-v $(ZENN_BASEDIR):/work \
		$(REPO):$(VERSION) $(ZENN_COMMAND) \
	; else echo "already running." ; fi

stop:
	@if docker ps | grep -q "$(CONTAINERNAME)" ; then docker stop "$(CONTAINERNAME)" ; else echo "not running." ; fi

# You can use busybox based commands including /bin/ash
attach:
	@if docker ps | grep -q "$(CONTAINERNAME)" ; then docker exec -it "$(CONTAINERNAME)" /bin/sh ; else echo "not running." ; fi

check:
	@if ! docker ps | grep -q "$(CONTAINERNAME)" ; then echo "not running." ; else echo "running." ; fi

testdir:
	@if test -d "$(ZENN_BASEDIR)" ; then echo "$(ZENN_BASEDIR) directory exist." ; else echo "$(ZENN_BASEDIR) directory not exist" ; fi


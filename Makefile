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

#
# build docker image
#

# testing Common Name for self signed certificate
#BUILD_CERT_CN=--build-arg cert_cn=apprtc.japaneast.azurecontainer.io

build:
	@if docker image ls "$(REPO):$(VERSION)" | grep "$(REPO)" ; then echo "image already exist." ; else \
		docker build -t "$(REPO):$(VERSION)" $(BUILD_SERVER_IP) $(BUILD_SERVER_PORT) $(BUILD_CERT_CN) . \
	; fi


# "docker image ls" will not set result code so use grep to set result code
ls:
	@if docker image ls "$(REPO):$(VERSION)" | grep "$(REPO)" ; then echo "image exist." ; else echo "image not exist." ; fi

rm:
	@docker image rm "$(REPO):$(VERSION)"

# docker push requres "docker login" beforhand. use docker hub account and password.
push:
	docker login && docker push "$(REPO):$(VERSION)"

#
# run docker imaghe
#

# containername for run/stop/attach/check
# you can use any name you like
CONTAINERNAME=my_zenn_preview

# if we didn't cache docker image locally, download specified image from docker hub

# default network mode = bridge when --network option not specified in "docker run" command.

# detach and run in background (-d)
# use host port 80 : docker port 8000
# no interractive mode and no terminal attach (no "-it")
# if you use "-it" (interactive shell) option, you can detach shell by pressing Ctrl-P Ctrl-Q

run:
	@if ! docker ps | grep -q "$(CONTAINERNAME)" ; then \
		sudo docker run --name="$(CONTAINERNAME)" \
		-d \
		-p 80:8000 \
		-v $(ZENN_BASEDIR):/work \
		$(REPO):$(VERSION) \
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


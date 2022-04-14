#######DEMO APP, DO NOT USE THIS FOR ANYTHING BUT TESTING PURPOSES, ITS NOT MEANT FOR PRODUCTION######

# Use alpine Linux supported by node distribution
# see https://github.com/nodejs/docker-node
FROM node:14-alpine3.15

# options for SSL Certificate common name (also used for Subject Alt Name)
# this is only used in docker build time
ARG cert_cn="localhost"

# install git, tini, openssl
RUN apk add --no-cache --update git tini openssl

# global install zenn-cli, no need to "npm init"
RUN npm install -g @types/markdown-it
RUN npm install -g --unsafe-perm zenn-cli@latest

# use /work for zenn content directory
WORKDIR /work

# create self signed certificate. check /cert/cert.cnf for configurations
RUN mkdir /cert
RUN printf "[dn]\nCN=${cert_cn}\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:${cert_cn}\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth" > /cert/cert.cnf
RUN openssl req -x509 -out /cert/cert.crt -keyout /cert/key.pem \
  -newkey rsa:2048 -nodes -sha256 \
  -subj "/CN=${cert_cn}" -extensions EXT -config /cert/cert.cnf \
  && cat /cert/key.pem > /cert/cert.pem \
  && cat /cert/cert.crt >> /cert/cert.pem \
  && chmod 600 /cert/cert.pem /cert/key.pem /cert/cert.crt

# start preview
# note : default port = 8000 but you can use any port using docker -v command line option
# optionally you can mount zenn content directory as "/work"
EXPOSE 8000
ENTRYPOINT ["/sbin/tini", "--", "npx", "zenn"]

# default command = "preview". You can use "new:article" or other zenn cli commands.
CMD ["preview"]

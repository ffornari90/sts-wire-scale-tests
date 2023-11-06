#!/bin/bash
ROOTDIR=$(git rev-parse --show-toplevel)
if ! [[ $# -eq 1 ]] ; then
    echo 'ERROR: You must provide a client index.'
    exit 1
fi
CLIDIR="${ROOTDIR}/scripts/sts-wire/conf/client$1"
CONFILE="${ROOTDIR}/scripts/sts-wire/conf/configs/config-$1.yml"
KEYFILE="${ROOTDIR}/scripts/sts-wire/conf/certs/client$1/private.key"
CRTFILE="${ROOTDIR}/scripts/sts-wire/conf/certs/client$1/public.crt"
if [ -d "$CLIDIR" ] && [ -f "$CONFILE" ] && [ -f "$KEYFILE" ] && [ -f "$CRTFILE" ]; then
    docker run --name="sts-wire-client$1" \
           --net=host -d \
           --device /dev/fuse \
           --cap-add SYS_ADMIN \
           --privileged \
           -v "${CLIDIR}":/home/docker/client \
           -v "${KEYFILE}":/home/docker/private.key \
           -v "${CRTFILE}":/home/docker/public.crt \
           -v "${CONFILE}":/home/docker/config.yml \
           sts-wire:rados \
           sh -x -c 'mkdir -p $HOME/rgw /tmp/rclone && \
           AUDIENCE=$(cat $HOME/config.yml | grep audience \
           | awk '"'"'{print $2}'"'"') && \
           IAM_URL=$(cat $HOME/config.yml | grep IAM_Server \
           | awk '"'"'{print $2}'"'"') && \
           RGW_URL=$(cat $HOME/config.yml | grep s3_endpoint \
           | awk '"'"'{print $2}'"'"') && \
           if [ ! -f "${HOME}/client/client.json" ]; then \
           http $IAM_URL/iam/api/client-registration \
           < $HOME/client/client-req.json \
           > $HOME/client/client.json; fi && \
           . $HOME/get_access_token.sh && \
           sts-wire --config config.yml \
           --localCache full --tryRemount \
           --noDummyFileCheck \
           --localCacheDir "/tmp/rclone"'
fi

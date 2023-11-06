FROM ubuntu:22.04
ARG USER_UID
ARG USER_GID
COPY ./install_phantomjs.sh /
RUN groupadd --system --gid $USER_GID docker && \
    adduser --gecos '' --disabled-password --system --uid $USER_UID \
    --ingroup docker --home /home/docker docker && \
    DEBIAN_FRONTEND=noninteractive apt update && \
    DEBIAN_FRONTEND=noninteractive apt install -y \
    ca-certificates curl wget gettext-base gpg gpg-agent oidc-agent \
    git make golang patch build-essential fuse fio httpie && \
    DEBIAN_FRONTEND=noninteractive apt clean && \
    wget "http://repository.egi.eu/sw/production/cas/1/current/tgz/" && \
    mkdir tgz certificates && for tgz in $(cat index.html | awk -F'"' '{print $2}' | grep tar.gz); \
    do wget http://repository.egi.eu/sw/production/cas/1/current/tgz/$tgz -O tgz/$tgz; \
    done && for tgz in $(ls tgz/); do tar xzf tgz/$tgz --strip-components=1 -C certificates/; \
    done && for f in $(find certificates/ -type f -name "*.pem"); \
    do cat $f >> /etc/ssl/certs/ca-certificates.crt; done && \
    wget "https://crt.sh/?d=2475254782" -O /etc/ssl/certs/geant-ov-rsa-ca.crt && \
    cat /etc/ssl/certs/geant-ov-rsa-ca.crt >> /etc/ssl/certs/ca-certificates.crt && \
    rm -rf tgz certificates && \
    git clone --branch rados https://github.com/DODAS-TS/sts-wire.git && \
    cd sts-wire && make build-linux-with-rclone && mv sts-wire_linux /usr/local/bin/sts-wire && \
    cd .. && rm -rf sts-wire /root/go && \
    /install_phantomjs.sh 
COPY ./login.js /home/docker/
COPY ./authorize.js /home/docker/
COPY ./run_phantomjs.sh /home/docker/
COPY ./get_access_token.sh /home/docker/
RUN chown docker:docker -R /home/docker
USER docker
WORKDIR /home/docker

#  This container needs to run with a mongodb instance!!! Use the docker-compose.yml to save your time

FROM centos:7
MAINTAINER Knifehands

ENV container docker

USER root
RUN echo 'Update the image and get the basics'
RUN yum -y update && yum -y install git openssh sudo vim wget
RUN echo 'Grabbing EPEL, RpmForge, CERT Forensics Repos'
RUN rpm --import http://apt.sw.be/RPM-GPG-KEY.dag.txt && \
    rpm -i http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el7.rf.x86_64.rpm
RUN yum -y install epel-release
WORKDIR /tmp
RUN wget https://forensics.cert.org/cert-forensics-tools-release-el7.rpm && \
    rpm -i cert-forensics-tools-release-el7.rpm && \
    rm cert-forensics-tools-release-el7.rpm
RUN echo 'Installing Packages'
RUN yum clean all
RUN yum -y install make \
    gcc \
    gcc-c++ \
    kernel-devel
RUN yum -y install openldap-devel \
    pcre \
    pcre-devel \
    curl \
    libpcap-devel \
    python-devel \
    python-pip \
    libxml2-devel \
    libxslt-devel \
    libyaml-devel \
RUN yum -y install numactl \
    ssdeep \
    ssdeep-devel \
    openssl-devel \
    zip \
    unzip \
    gzip \
    bzip2 \
    swig \
    m2crypto \
    python-pillow \
    python-lxml
RUN yum -y install p7zip \
    p7zip-plugins \
    libffi-devel \
    libyaml \
    upx \
    yara \
    yara-python
####Make /data for all the CRITs goodness ####
RUN mkdir /data
#### Fetch the CRITs Codebase ####
WORKDIR /data
RUN git clone https://github.com/crits/crits.git && \
    git clone https://github.com/crits/crits_services.git
#### Adjust permissions ####
RUN useradd -r -s /bin/false crits && \
    chown -R crits /data && \
    chmod -R -v 0755 /data && \
    touch /data/crits/logs/crits.log && \
    chgrp -R crits /data/crits/logs && \
    chmod 0644 /data/crits/logs/crits.log
#### Install Python Dependencies ####
RUN echo 'Installing Python Dependencies'
WORKDIR /data/crits
RUN pip install --upgrade pip
RUN pip install -r requirements.txt
#### Need gunicorn so we can run the proxy on a different image ####
RUN pip install gunicorn
#### Need to add a gunicorn.conf somehow... Perhaps provide an additional git clone? or Maybe run this using a local config dir? Or, maybe we can have zookeeper provide the configs?
#### Prepare the Database ####
RUN cp crits/config/database_example.py crits/config/database.py && \
    SC=$(cat /dev/urandom | LC_CTYPE=C tr -dc 'abcdefghijklmnopqrstuvwxyz0123456789!@#%^&*(-_=+)' | fold -w 50 | head -n 1) && \
    SE=$(echo ${SC} | sed -e 's/\\/\\\\/g' | sed -e 's/\//\\\//g' | sed -e 's/&/\\\&/g') && \
    sed -i -e "s/^\(SECRET_KEY = \).*$/\1\'${SE}\'/1" crits/config/database.py && \
    sed -i -e "s/^\(MONGO_HOST = \).*$/\1\os.environ['MONGODB_PORT_27017_TCP_ADDR']/1" crits/config/database.py  # need to change the mongo host to the docker image name
# TODO need to check for the default collections, then if they exist offer a chance to run the upgrade command
RUN echo 'Building Default Collections'
WORKDIR /data/crits
RUN python manage.py create_default_collections
RUN echo 'Set up a default admin'
RUN python manage.py users -a -A -e admin@foo.org -f admin -l admin -o foo -u admin
RUN echo 'Starting runserver'
RUN python manage.py runserver 0.0.0.0:8080
EXPOSE 8080


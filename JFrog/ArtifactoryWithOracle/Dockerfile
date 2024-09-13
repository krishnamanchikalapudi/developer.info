ARG ARTIFACTORY_VERSION="7.84.14"
# Download oracle clien from https://www.oracle.com/database/technologies/instant-client/linux-x86-64-downloads.html
ARG ORACLE_DRIVER_URL="https://download.oracle.com/otn_software/linux/instantclient/2115000/instantclient-basic-linux.x64-21.15.0.0.0dbru.zip"

# Base image
FROM releases-docker.jfrog.io/jfrog/artifactory-pro:${ARTIFACTORY_VERSION}
ARG ORACLE_DRIVER_NAME="oracle-instantclient.zip"

USER root
# installing unzip, wget
RUN apt-get install unzip wget -y
# creating folder
RUN mkdir -p /opt/oracle/
# Download oracle client
RUN wget -O /tmp/${ORACLE_DRIVER_NAME} ${ORACLE_DRIVER_URL}

COPY /tmp/${ORACLE_DRIVER_NAME} /opt/oracle/
RUN mkdir -p /opt/oracle/instantclient && cd /opt/oracle/instantclient && \
    unzip -j /tmp/${ORACLE_DRIVER_NAME} && \
    cp /opt/jfrog/artifactory/app/artifactory/libaio/* ./ && \
    chown -R artifactory:artifactory /opt/oracle/instantclient
USER artifactory
ENV LD_LIBRARY_PATH="/opt/oracle/instantclient"
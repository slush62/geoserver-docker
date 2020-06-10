FROM tomcat:9-jre8
MAINTAINER GeoNode Development Team

#
# Set GeoServer version and data directory
#
ENV GEOSERVER_VERSION=2.16.2
ENV GEOSERVER_DATA_DIR="/geoserver_data/data"

#
# Download and install GeoServer
#
RUN cd /usr/local/tomcat/webapps \
    && wget --no-check-certificate --progress=bar:force:noscroll \
    https://build.geo-solutions.it/geonode/geoserver/latest/geoserver-${GEOSERVER_VERSION}.war \
    && unzip -q geoserver-${GEOSERVER_VERSION}.war -d geoserver \
    && rm geoserver-${GEOSERVER_VERSION}.war \
    && mkdir -p $GEOSERVER_DATA_DIR

VOLUME $GEOSERVER_DATA_DIR

###########docker host###############
# Set DOCKERHOST variable if DOCKER_HOST exists
ARG DOCKERHOST=${DOCKERHOST}
# for debugging
RUN echo -n #1===>DOCKERHOST=${DOCKERHOST}
#
ENV DOCKERHOST ${DOCKERHOST}
# for debugging
RUN echo -n #2===>DOCKERHOST=${DOCKERHOST}

###########docker host ip#############
# Set GEONODE_HOST_IP address if it exists
ARG GEONODE_HOST_IP=${GEONODE_HOST_IP}
# for debugging
RUN echo -n #1===>GEONODE_HOST_IP=${GEONODE_HOST_IP}
#
ENV GEONODE_HOST_IP ${GEONODE_HOST_IP}
# for debugging
RUN echo -n #2===>GEONODE_HOST_IP=${GEONODE_HOST_IP}
# If empty set DOCKER_HOST_IP to GEONODE_HOST_IP
ENV DOCKER_HOST_IP=${DOCKER_HOST_IP:-${GEONODE_HOST_IP}}
# for debugging
RUN echo -n #1===>DOCKER_HOST_IP=${DOCKER_HOST_IP}
# Trying to set the value of DOCKER_HOST_IP from DOCKER_HOST
RUN if ! [ -z ${DOCKER_HOST_IP} ]; \
    then echo export DOCKER_HOST_IP=${DOCKERHOST} | \
    sed 's/tcp:\/\/\([^:]*\).*/\1/' >> /root/.bashrc; \
    else echo "DOCKER_HOST_IP is already set!"; fi
# for debugging
RUN echo -n #2===>DOCKER_HOST_IP=${DOCKER_HOST_IP}

# Set WEBSERVER public port
ARG PUBLIC_PORT=${PUBLIC_PORT}
# for debugging
RUN echo -n #1===>PUBLIC_PORT=${PUBLIC_PORT}
#
ENV PUBLIC_PORT=${PUBLIC_PORT}
# for debugging
RUN echo -n #2===>PUBLIC_PORT=${PUBLIC_PORT}

# set nginx base url for geoserver
RUN echo export NGINX_BASE_URL=http://${NGINX_HOST}:${NGINX_PORT}/ | \
    sed 's/tcp:\/\/\([^:]*\).*/\1/' >> /root/.bashrc

# copy the script and perform the run of scripts from entrypoint.sh
RUN mkdir -p /usr/local/tomcat/tmp
WORKDIR /usr/local/tomcat/tmp
COPY set_geoserver_auth.sh /usr/local/tomcat/tmp
COPY setup_auth.sh /usr/local/tomcat/tmp
COPY requirements.txt /usr/local/tomcat/tmp
COPY get_dockerhost_ip.py /usr/local/tomcat/tmp
COPY get_nginxhost_ip.py /usr/local/tomcat/tmp
COPY entrypoint.sh /usr/local/tomcat/tmp

RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get install -y gdal-bin libgdal-java \
    && apt-get install -y python python-pip python-dev \
    && chmod +x /usr/local/tomcat/tmp/set_geoserver_auth.sh \
    && chmod +x /usr/local/tomcat/tmp/setup_auth.sh \
    && chmod +x /usr/local/tomcat/tmp/entrypoint.sh \
    && pip install pip==9.0.3 \
    && pip install -r requirements.txt \
    && chmod +x /usr/local/tomcat/tmp/get_dockerhost_ip.py \
    && chmod +x /usr/local/tomcat/tmp/get_nginxhost_ip.py

# Peraton extensions
# RUN wget --no-check-certificate https://build.geo-solutions.it/geonode/geoserver/latest/geonode-geoserver-ext-web-app-${GEOSERVER_VERSION}-geoserver-plugin.zip \
#     && unzip -o -d /usr/local/tomcat/webapps/geoserver/WEB-INF/lib/ geonode-geoserver-ext-web-app-${GEOSERVER_VERSION}-geoserver-plugin.zip \
RUN wget --no-check-certificate https://build.geoserver.org/geoserver/2.16.x/ext-latest/geoserver-2.16-SNAPSHOT-gdal-plugin.zip \
    && unzip -o -d /usr/local/tomcat/webapps/geoserver/WEB-INF/lib/ geoserver-2.16-SNAPSHOT-gdal-plugin.zip \
    && wget --no-check-certificate https://demo.geo-solutions.it/share/github/imageio-ext/releases/1.1.X/1.1.10/native/gdal/gdal-data.zip \
    && mkdir -p /usr/share/gdal/2.2 \
    && unzip -o -d /usr/share/gdal/2.2 gdal-data.zip \ 
    && wget https://build.geoserver.org/geoserver/2.16.x/ext-latest/geoserver-2.16-SNAPSHOT-netcdf-plugin.zip \
    && unzip -o -d /usr/local/tomcat/webapps/geoserver/WEB-INF/lib/ geoserver-2.16-SNAPSHOT-netcdf-plugin.zip \
    && wget https://build.geoserver.org/geoserver/2.16.x/ext-latest/geoserver-2.16-SNAPSHOT-netcdf-out-plugin.zip \
    &&  unzip -o -d /usr/local/tomcat/webapps/geoserver/WEB-INF/lib/ geoserver-2.16-SNAPSHOT-netcdf-out-plugin.zip \
    && wget https://build.geoserver.org/geoserver/2.16.x/ext-latest/geoserver-2.16-SNAPSHOT-grib-plugin.zip \
    && unzip -o -d /usr/local/tomcat/webapps/geoserver/WEB-INF/lib/ geoserver-2.16-SNAPSHOT-grib-plugin.zip \
    && wget https://build.geoserver.org/geoserver/2.16.x/ext-latest/geoserver-2.16-SNAPSHOT-libjpeg-turbo-plugin.zip \
    && unzip -o -d /usr/local/tomcat/webapps/geoserver/WEB-INF/lib/ geoserver-2.16-SNAPSHOT-libjpeg-turbo-plugin.zip \
    && wget --no-check-certificate https://build.geo-solutions.it/geonode/geoserver/latest/data-${GEOSERVER_VERSION}.zip \
    && unzip -o -d /geoserver_data data-${GEOSERVER_VERSION}.zip 

COPY libjpeg-turbo-official_2.0.4_amd64.deb .
RUN apt install -y ./libjpeg-turbo-official_2.0.4_amd64.deb

COPY setenv.sh /usr/local/tomcat/bin/

ENV JAVA_OPTS="-Djava.awt.headless=true -XX:MaxPermSize=512m -XX:PermSize=256m -Xms512m -Xmx2048m -XX:+UseConcMarkSweepGC -XX:+UseParNewGC -XX:ParallelGCThreads=4 -Dfile.encoding=UTF8 -Duser.timezone=GMT -Djavax.servlet.request.encoding=UTF-8 -Djavax.servlet.response.encoding=UTF-8 -Duser.timezone=GMT -Dorg.geotools.shapefile.datetime=true"

CMD ["/usr/local/tomcat/tmp/entrypoint.sh"]

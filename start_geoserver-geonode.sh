#docker run -it --rm --name=geoserver --network=geoswarm \
docker run -it -d --restart=always --name=geoserver --network=geoswarm \
-e GEOSERVER_DATA_DIR=/geoserver_data/data \
-e GEOSERVER_DATA_ROOT=/geoserver_data \
-e GEOSERVER_ADMIN_USER=geoserver \
-e GEOSERVER_ADMIN_PASSWORD=geoserver \
-v /var/run/docker.sock:/var/run/docker.sock \
-v /opt/docker/geoserver/data:/geoserver_data/data:Z \
-p 8080:8080 docker/geoserver

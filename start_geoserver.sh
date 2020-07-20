#docker run -it --rm --name=geoserver --network=geoswarm \
docker run -it -d --restart=always --name=geoserver --network=geoswarm \
-e STABLE_EXTENSIONS=gdal-plugin,libjpeg-turbo-plugin,grib-plugin,importer-plugin \
-v /home/docker/geoserver/data:/opt/geoserver/data_dir:Z \
-p 8080:8080 docker.io/kartoza/geoserver

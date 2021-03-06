FROM openjdk:8-jre-alpine

# Install Java JAI libraries
RUN \
    apk add --no-cache ca-certificates curl && \
    cd /tmp && \
    curl -L http://download.java.net/media/jai/builds/release/1_1_3/jai-1_1_3-lib-linux-amd64.tar.gz | tar xfz - && \
    curl -L http://download.java.net/media/jai-imageio/builds/release/1.1/jai_imageio-1_1-lib-linux-amd64.tar.gz  | tar xfz - && \
    mv /tmp/jai*/lib/*.jar $JAVA_HOME/lib/ext/  && \
    mv /tmp/jai*/lib/*.so $JAVA_HOME/lib/amd64/  && \
    rm -r /tmp/*
    
# Install geoserver and plugins (importer)
ARG GS_VERSION=2.13.0
ENV GEOSERVER_HOME /geoserver-$GS_VERSION
RUN \
    curl -L http://downloads.sourceforge.net/project/geoserver/GeoServer/${GS_VERSION}/geoserver-${GS_VERSION}-bin.zip > /tmp/geoserver.zip && \
    unzip -q /tmp/geoserver.zip -d / && \
    chgrp -R 0 $GEOSERVER_HOME && \
    chmod -R g+rwX $GEOSERVER_HOME && \
    cd $GEOSERVER_HOME/webapps/geoserver/WEB-INF/lib  && \
    rm jai_core-*jar jai_imageio-*.jar jai_codec-*.jar  && \
    curl -L http://sourceforge.net/projects/geoserver/files/GeoServer/${GS_VERSION}/extensions/geoserver-${GS_VERSION}-importer-plugin.zip > /tmp/geoserver-importer-plugin.zip && \
    unzip -o /tmp/geoserver-importer-plugin.zip -d $CATALINA_HOME/webapps/geoserver/WEB-INF/lib/ && \ 
    apk del curl  && \
    rm -r /tmp/* 
    
ENV JAVA_OPTS "-server -Xms128m -Xmx384m"

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh 
CMD /entrypoint.sh 

EXPOSE 8080


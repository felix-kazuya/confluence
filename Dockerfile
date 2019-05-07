ARG     IMAGE=felixkazuyadev/openjava-base
ARG     TAG=latest
FROM $IMAGE:$TAG
MAINTAINER Christian Walonka <christian@walonka.de>
MAINTAINER Christian Walonka <cwalonka@it-economics.de>

RUN apt-get update && apt-get install -y graphviz 

ARG INSTALLDIR=/opt/atlassian/confluence
ENV INSTALLDIR=${INSTALLDIR}
ARG VERSION=atlassian-confluence-6.15.2-x64.bin
ARG DOWNLOADPATH=https://www.atlassian.com/software/confluence/downloads/binary
ARG SERVERPORT=8080
ENV SERVERPORT=${SERVERPORT}
ARG HTTPSSERVERPORT=8443
ENV HTTPSSERVERPORT=${HTTPSSERVERPORT}
ARG AJPSERVERPORT=9080
ENV AJPSERVERPORT=${AJPSERVERPORT}

ENV REFRESHED_AT 2019-03-04
RUN wget $DOWNLOADPATH/$VERSION && \
chmod +x $VERSION && \
touch response.varfile && \
echo "rmiPort\$Long=8005">>response.varfile && \
echo "app.install.service$Boolean=true">>response.varfile && \
echo "existingInstallationDir=$INSTALLDIR">>response.varfile && \
echo "sys.confirmedUpdateInstallationString=false">>response.varfile && \
echo "sys.languageId=en">>response.varfile && \
echo "sys.installationDir=$INSTALLDIR">>response.varfile && \
echo "app.confHome=/var/atlassian/application-data/confluence">>response.varfile && \
echo "executeLauncherAction$Boolean=true">>response.varfile && \
echo "httpPort\$Long=$SERVERPORT">>response.varfile && \
echo "portChoice=default">>response.varfile && \
./$VERSION -q -varfile response.varfile && \
ln -n /usr/share/java/mysql-connector-java.jar $INSTALLDIR/lib/mysql-connector-java.jar && \
rm $VERSION

COPY files/server.xml $INSTALLDIR/conf/server.xml
RUN mkdir -p  $INSTALLDIR/ext
COPY files/rewrite.config $INSTALLDIR/ext/rewrite.config

EXPOSE $SERVERPORT $HTTPSSERVERPORT $AJPSERVERPORT

COPY entrypoint /entrypoint
RUN chmod +x /entrypoint
CMD [ "/entrypoint" ]

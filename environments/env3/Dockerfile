FROM tomcat:10.1-jdk17
RUN rm -rf /usr/local/tomcat/webapps/*
COPY server.xml /usr/local/tomcat/conf/server.xml
COPY keystore.jks /usr/local/tomcat/conf/keystore.jks
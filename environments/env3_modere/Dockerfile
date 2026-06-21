FROM tomcat:10.1-jdk17
RUN cp -r /usr/local/tomcat/webapps.dist/manager /usr/local/tomcat/webapps/manager
COPY server.xml /usr/local/tomcat/conf/server.xml
COPY keystore.jks /usr/local/tomcat/conf/keystore.jks
COPY context.xml /usr/local/tomcat/webapps/manager/META-INF/context.xml
FROM tomcat:10.1-jdk17
# Delete default webapps as required for production [cite: 121]
RUN rm -rf /usr/local/tomcat/webapps/*
COPY server.xml /usr/local/tomcat/conf/server.xml
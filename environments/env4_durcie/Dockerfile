FROM tomcat:10.1-jdk17
RUN rm -rf /usr/local/tomcat/webapps/*
# Enforce non-root process execution [cite: 81]
COPY --chown=1001:1001 server.xml /usr/local/tomcat/conf/server.xml
COPY --chown=1001:1001 web.xml /usr/local/tomcat/conf/web.xml
COPY --chown=1001:1001 tomcat-users.xml /usr/local/tomcat/conf/tomcat-users.xml
COPY --chown=1001:1001 keystore.jks /usr/local/tomcat/conf/keystore.jks
USER 1001
FROM tomcat:10.1-jdk17
# We keep manager utility but super light near non-existant configs
RUN cp -r /usr/local/tomcat/webapps.dist/manager /usr/local/tomcat/webapps/manager
COPY server.xml /usr/local/tomcat/conf/server.xml
COPY context.xml /usr/local/tomcat/webapps/manager/META-INF/context.xml
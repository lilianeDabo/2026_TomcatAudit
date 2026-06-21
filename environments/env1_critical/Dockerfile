FROM tomcat:10.1-jdk17
# Bring back the default webapps
RUN cp -r /usr/local/tomcat/webapps.dist/* /usr/local/tomcat/webapps/
# Completely strip out any RemoteCIDRValve or RemoteAddrValve restrictions
RUN sed -i '/RemoteCIDRValve/d' /usr/local/tomcat/webapps/manager/META-INF/context.xml
RUN sed -i '/RemoteAddrValve/d' /usr/local/tomcat/webapps/manager/META-INF/context.xml
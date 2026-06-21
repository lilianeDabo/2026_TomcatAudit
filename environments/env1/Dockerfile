FROM tomcat:10.1-jdk17
# Bring back the default webapps
RUN cp -r /usr/local/tomcat/webapps.dist/* /usr/local/tomcat/webapps/
# Modify context.xml to remove RemoteAddrValve completely so anyone can access it remotely
RUN sed -i '/Valve className="org.apache.catalina.valves.RemoteAddrValve"/d' /usr/local/tomcat/webapps/manager/META-INF/context.xml
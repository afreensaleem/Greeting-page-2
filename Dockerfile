# Use official Tomcat base image
FROM tomcat:10.1.12-jdk17

# Remove default webapps to avoid clutter
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy the project into Tomcat's webapps/ROOT folder
COPY . /usr/local/tomcat/webapps/ROOT

# Ensure WEB-INF/lib and classes directories exist and set permissions
RUN mkdir -p /usr/local/tomcat/webapps/ROOT/WEB-INF/lib && \
    mkdir -p /usr/local/tomcat/webapps/ROOT/WEB-INF/classes && \
    chmod -R 755 /usr/local/tomcat/webapps/ROOT/WEB-INF

# Copy dependencies to WEB-INF/lib
RUN cp /usr/local/tomcat/webapps/ROOT/lib/*.jar /usr/local/tomcat/webapps/ROOT/WEB-INF/lib/

# Compile FlaskClient.java and move to WEB-INF/classes
RUN javac -cp ".:/usr/local/tomcat/webapps/ROOT/lib/*" /usr/local/tomcat/webapps/ROOT/FlaskClient.java && \
    mv /usr/local/tomcat/webapps/ROOT/FlaskClient.class /usr/local/tomcat/webapps/ROOT/WEB-INF/classes/

# Expose Tomcat default port
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]

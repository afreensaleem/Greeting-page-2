# Use official Tomcat base image
FROM tomcat:10.1.12-jdk17

# Remove default webapps to avoid clutter
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy the project into Tomcat's webapps/ROOT folder
COPY . /usr/local/tomcat/webapps/ROOT

# Ensure WEB-INF/lib and classes directories exist and set permissions
RUN mkdir -p /usr/local/tomcat/webapps/ROOT/WEB-INF/lib && \
    mkdir -p /usr/local/tomcat/webapps/ROOT/WEB-INF/classes/helper && \
    chmod -R 755 /usr/local/tomcat/webapps/ROOT/WEB-INF

# Create lib/ directory if it doesn't exist and copy dependencies to WEB-INF/lib
RUN mkdir -p /usr/local/tomcat/webapps/ROOT/lib && \
    sh -c 'cp /usr/local/tomcat/webapps/ROOT/lib/*.jar /usr/local/tomcat/webapps/ROOT/WEB-INF/lib/ || true'

# Debug: List directory contents to verify file presence
RUN echo "Listing contents of /usr/local/tomcat/webapps/ROOT:" && \
    ls -la /usr/local/tomcat/webapps/ROOT && \
    echo "Listing contents of /usr/local/tomcat/webapps/ROOT/helper:" && \
    ls -la /usr/local/tomcat/webapps/ROOT/helper || true && \
    echo "Listing contents of /usr/local/tomcat/webapps/ROOT/WEB-INF/classes/helper:" && \
    ls -la /usr/local/tomcat/webapps/ROOT/WEB-INF/classes/helper || true

# Compile FlaskClient.java from either helper/ or WEB-INF/classes/helper/ and move to WEB-INF/classes/helper
RUN if [ -f /usr/local/tomcat/webapps/ROOT/helper/FlaskClient.java ]; then \
      echo "Found FlaskClient.java in helper/"; \
      javac -cp ".:/usr/local/tomcat/webapps/ROOT/lib/*" /usr/local/tomcat/webapps/ROOT/helper/FlaskClient.java && \
      mv /usr/local/tomcat/webapps/ROOT/helper/FlaskClient.class /usr/local/tomcat/webapps/ROOT/WEB-INF/classes/helper/; \
    elif [ -f /usr/local/tomcat/webapps/ROOT/WEB-INF/classes/helper/FlaskClient.java ]; then \
      echo "Found FlaskClient.java in WEB-INF/classes/helper/"; \
      javac -cp ".:/usr/local/tomcat/webapps/ROOT/lib/*" /usr/local/tomcat/webapps/ROOT/WEB-INF/classes/helper/FlaskClient.java && \
      mv /usr/local/tomcat/webapps/ROOT/WEB-INF/classes/helper/FlaskClient.class /usr/local/tomcat/webapps/ROOT/WEB-INF/classes/helper/; \
    else \
      echo "Error: FlaskClient.java not found in helper/ or WEB-INF/classes/helper/"; \
      ls -la /usr/local/tomcat/webapps/ROOT/helper || true; \
      ls -la /usr/local/tomcat/webapps/ROOT/WEB-INF/classes/helper || true; \
      exit 1; \
    fi

# Expose Tomcat default port
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]


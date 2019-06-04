#wildfly 8.2.1 with openjdk 8
FROM jboss/wildfly:8.2.1.Final

# Appserver
ENV WILDFLY_USER admin
ENV WILDFLY_PASS adminPassword
ENV WILDFLY_USERAPP user
ENV WILDFLY_USERPWD password
ENV WILDFLY_USERGROUP user
ENV WILDFLY_DS_NAME MySQLDS

# Database
ENV DB_NAME ipstddb
ENV DB_USER ipst
ENV DB_PASS ipst
ENV DB_URI db:3306

# mysql jdbc drivers
ENV MYSQL_VERSION 5.1.23
ENV JBOSS_CLI /opt/jboss/wildfly/bin/jboss-cli.sh
ENV DEPLOYMENT_DIR /opt/jboss/wildfly/standalone/deployments/
#ENV JAVA_OPTS

# Setting up WildFly
RUN echo "=> Adding WildFly administrator user" && \
      $JBOSS_HOME/bin/add-user.sh -u $WILDFLY_USER -p $WILDFLY_PASS --silent && \
    echo "=> Adding WildFly app user" && \
      $JBOSS_HOME/bin/add-user.sh -a -u $WILDFLY_USERAPP -p $WILDFLY_USERPWD -g $WILDFLY_USERGROUP --silent && \
    echo "=> Starting WildFly server" && \
      bash -c '$JBOSS_HOME/bin/standalone.sh &' && \
    echo "=> Waiting for the server to boot" && \
      bash -c 'until `$JBOSS_CLI -c ":read-attribute(name=server-state)" 2> /dev/null | grep -q running`; do echo `$JBOSS_CLI -c ":read-attribute(name=server-state)" 2> /dev/null`; sleep 1; done' && \
    echo "=> Downloading MySQL driver" && \
      export http_proxy=${http_proxy} && \
      curl --location --output /tmp/mysql-connector-java-${MYSQL_VERSION}.jar --url http://search.maven.org/remotecontent?filepath=mysql/mysql-connector-java/${MYSQL_VERSION}/mysql-connector-java-${MYSQL_VERSION}.jar && \
      unset http_proxy && \
    echo "=> Adding MySQL module" && \
      $JBOSS_CLI --connect --command="module add --name=com.mysql --resources=/tmp/mysql-connector-java-${MYSQL_VERSION}.jar --dependencies=javax.api,javax.transaction.api" && \
    echo "=> Adding MySQL driver" && \
                                     #/subsystem=datasources/jdbc-driver=mysql:add(driver-name=mysql,driver-module-name=com.mysql.driver,driver-class-name=com.mysql.jdbc.Driver)
      $JBOSS_CLI --connect --command="/subsystem=datasources/jdbc-driver=mysql:add(driver-name=mysql,driver-module-name=com.mysql,driver-xa-datasource-class-name=com.mysql.jdbc.jdbc2.optional.MysqlXADataSource)" && \
    echo "=> Creating a new datasource" && \
      $JBOSS_CLI --connect --command="data-source add \
        --name=${WILDFLY_DS_NAME} \
        --jndi-name=java:/${WILDFLY_DS_NAME} \
        --user-name=${DB_USER} \
        --password=${DB_PASS} \
        --driver-name=mysql \
        --connection-url=jdbc:mysql://${DB_URI}/${DB_NAME}?useUnicode=true&amp;connectionCollation=utf8_general_ci&amp;characterSetResults=utf8&amp;characterEncoding=utf8 \
        --use-ccm=false \
        --max-pool-size=25 \
        --blocking-timeout-wait-millis=5000 \
        --enabled=true" && \
    echo "=> Shutting down WildFly and Cleaning up" && \
      $JBOSS_CLI --connect --command=":shutdown" && \
      rm -rf $JBOSS_HOME/standalone/configuration/standalone_xml_history/ $JBOSS_HOME/standalone/log/* && \
      rm -f /tmp/*.jar

# Expose http and admin ports
EXPOSE 8080 9990

#copy the DDB ear file to the wildfly's deployment directory
COPY ./iidm-ddb-ear/target/ipst-ddb-ear.ear /opt/jboss/wildfly/standalone/deployments

# Set the default command to run on boot
# This will boot WildFly in the standalone mode and bind to all interfaces
CMD ["/opt/jboss/wildfly/bin/standalone.sh", "-b", "0.0.0.0", "-bmanagement", "0.0.0.0"]

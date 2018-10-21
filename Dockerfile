# Centos based container with Java and Tomcat
FROM centos:centos7
MAINTAINER bingqiao <bqiaodev@gmail.com>

# Install prepare infrastructure
RUN yum -y update && \
 yum -y install wget && \
 yum -y install tar

ENV JAVA_HOME /opt/java
ENV PATH $PATH:$JAVA_HOME/bin

RUN mkdir /jdk-source && \
 chmod 777 /jdk-source

# Install Oracle Java8
ARG JDK_FILE

ADD ./binaries/jdk/${JDK_FILE} /jdk-source/jdk

RUN mv /jdk-source/jdk/* ${JAVA_HOME}

# Create group and users
RUN groupadd -r tomcat && \
 useradd -g tomcat -c "user1" user1 && \
 echo 'user1:letmein' | chpasswd && \
 useradd -g tomcat -c "user2" user2 && \
 echo 'user2:letmein' | chpasswd

# Copy installation files
ARG TOMCAT_FILE

ADD ./binaries/tomcat/${TOMCAT_FILE} /home/user1/tmp
ADD ./binaries/tomcat/${TOMCAT_FILE} /home/user2/tmp
RUN mv /home/user1/tmp/* /home/user1/tomcat && \
 rm -rf /home/user1/tmp && \
 mv /home/user2/tmp/* /home/user2/tomcat && \
 rm -rf /home/user2/tmp && \
 sed -i 's/="8080"/="18080"/g;s/="8005"/="18005"/g;s/="8443"/="18443"/g;s/="8009"/="18009"/g' /home/user2/tomcat/conf/server.xml && \
 echo 'CATALINA_OPTS="-d64 -Xmx1024M $CATALINA_OPTS"' > /home/user2/tomcat/bin/setenv.sh && \
 chown -R user1:tomcat /home/user1/tomcat && \
 chmod +x /home/user1/tomcat/bin/*sh && \
 chown -R user2:tomcat /home/user2/tomcat && \
 chmod +x /home/user2/tomcat/bin/*sh

USER user1
RUN echo 'export CATALINA_HOME=$HOME/tomcat' >>~/.bash_profile && \
 echo 'export JAVA_HOME=/opt/java' >>~/.bash_profile && \
 echo 'export PATH=$PATH:$JAVA_HOME/bin:$CATALINA_HOME/bin' >>~/.bash_profile

USER user2
RUN echo 'export CATALINA_HOME=$HOME/tomcat' >>~/.bash_profile && \
 echo 'export JAVA_HOME=/opt/java' >>~/.bash_profile && \
 echo 'export PATH=$PATH:$JAVA_HOME/bin:$CATALINA_HOME/bin' >>~/.bash_profile

USER root

EXPOSE 8080
EXPOSE 18080

ADD init.sh /scripts/init.sh
# fix windows carriage return
RUN sed -i -e 's/\r$//' /scripts/init.sh

CMD ["./scripts/init.sh"]

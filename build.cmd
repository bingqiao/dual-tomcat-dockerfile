docker build --rm --no-cache --build-arg JDK_FILE=jdk-8u191-linux-x64.tar.gz  ^
--build-arg TOMCAT_FILE=apache-tomcat-8.5.34.tar.gz  ^
-t %1 .
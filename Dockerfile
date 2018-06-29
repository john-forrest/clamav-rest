# build stage 0 : generate /build/target/clamav-rest-1.0.2.jar
FROM maven as builder

RUN apt-get update && \
    apt-get upgrade -y && \
    update-ca-certificates

# install clamavd so it can be used in mvn-based unit tests, fix db just in case of compat issue.
RUN apt-get install -y clamav clamav-daemon && \
    freshclam

RUN mkdir -p /build
WORKDIR /build
COPY img /build/img/
COPY pom.xml /build/
COPY src /build/src/

RUN service clamav-daemon start && \
    mvn package

############################################################################
# MAIN build stage
FROM centos:7

# MAINTAINER lokori <antti.virtanen@iki.fi>

RUN yum update -y && \
    yum install -y java-1.8.0-openjdk-headless java-1.8.0-openjdk-devel && \
    yum clean all && \
    rm -rf /var/cache/yum

# Set environment variables.
ENV HOME /root

# Get the JAR file 
CMD mkdir -p /var/clamav-rest
COPY --from=builder /build/target/clamav-rest-1.0.2.jar /var/clamav-rest/

# Define working directory.
WORKDIR /var/clamav-rest/

# Open up the server 
EXPOSE 8080

ADD bootstrap.sh /
# handle windows \r's
RUN tr -d '\r' < /bootstrap.sh > .tmp && \
     mv .tmp /bootstrap.sh && \
     chmod a+x /bootstrap.sh
ENTRYPOINT ["/bootstrap.sh"]


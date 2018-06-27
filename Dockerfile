# build stage 0 : generate /build/target/clamav-rest-1.0.2.jar
FROM maven as builder
RUN apt-get upgrade -y && update-ca-certificates
RUN mkdir /build
WORKDIR /build
COPY img/ pom.xml src/ /build/
RUN mvn package

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
CMD mkdir /var/clamav-rest
COPY --from=builder /build/target/clamav-rest-1.0.2.jar /var/clamav-rest/

# Define working directory.
WORKDIR /var/clamav-rest/

# Open up the server 
EXPOSE 8080

ADD bootstrap.sh /
ENTRYPOINT ["/bootstrap.sh"]


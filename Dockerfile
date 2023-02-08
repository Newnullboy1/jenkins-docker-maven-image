FROM jenkins/jenkins:lts-jdk11

# Running as root to have an easy support for Docker
USER root

# A default admin user
ENV ADMIN_USER=admin \
    ADMIN_PASSWORD=password

# Jenkins init scripts
COPY security.groovy /usr/share/jenkins/ref/init.groovy.d/

# Install plugins at Docker image build time
COPY plugins.txt /usr/share/jenkins/ref/
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

# Install Docker
RUN apt-get -qq update && \
    apt-get -qq -y install curl && \
    curl -sSL https://get.docker.com/ | sh

# Install Maven
RUN curl -LO https://downloads.apache.org/maven/maven-3/3.8.7/binaries/apache-maven-3.8.7-bin.tar.gz && \
    tar xzf apache-maven-3.8.7-bin.tar.gz && \
    mv ./apache-maven-3.8.7 /opt/apache-maven | sh
ENV PATH=/opt/apache-maven/bin:$PATH
ENV _JAVA_OPTIONS=-Djdk.net.URLClassPath.disableClassPathURLCheck=true

# ENV M2_HOME="/opt/apache-maven"

# Install kubectl and helm
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin/kubectl && \
    curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash
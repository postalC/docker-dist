FROM ubuntu:14.04

#ENV http_proxy http://proxy.wdf.sap.corp:8080
#ENV https_proxy http://proxy.wdf.sap.corp:8080
ENV no_proxy sap.corp,wdf.sap.corp,localhost,127.0.0.1,moo-repo,169.254.169.254,repo

# install java7
RUN \
  echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true \
  | debconf-set-selections && \
  apt-get install -y software-properties-common && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java7-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk7-installer
ENV JAVA_HOME /usr/lib/jvm/java-7-oracle

# install openssh-server
RUN apt-get update && apt-get install -y \
  openssh-server \
  unzip \
  dos2unix \
  sysstat

# add apt-proxy
#RUN mkdir -p /etc/apt
#COPY apt.conf /etc/apt/

# enable sysstat
RUN sed 's/ENABLED="false"/ENABLED="true"/' /etc/default/sysstat

# add cityapp application admin
RUN useradd -m -d /home/cityapp -s /bin/bash -G sudo cityapp && \
  echo cityapp:caD0cker@sap | chpasswd
COPY startup.sh /home/cityapp/etc/
COPY sshd_config /home/cityapp/ssh/etc/
COPY simpleDeploy.sh /home/cityapp/deploy/

RUN chown -R cityapp:cityapp /home/cityapp && chmod -R a+x /home/cityapp
RUN mkdir -p /opt/cityapp
RUN mkdir -p /opt/cityapp/documentservice
RUN chown -R cityapp:cityapp /opt/cityapp && chmod -R a+x /opt/cityapp

# add cityapp support user
RUN useradd -m -d /home/casupport -s /bin/bash -g cityapp casupport && \
  echo casupport:P@ssw0rd11 | chpasswd

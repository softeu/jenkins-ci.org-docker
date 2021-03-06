FROM ubuntu:14.04

RUN echo "1.565.1" > .lts-version-number

RUN apt-get update && apt-get install -y wget git curl zip vim
RUN apt-get update && apt-get install -y --no-install-recommends openjdk-7-jdk openjdk-6-jdk
RUN apt-get update && apt-get install -y maven2 maven ant ruby rbenv make

RUN apt-get -qq update && apt-get -qqy install software-properties-common
RUN add-apt-repository -y ppa:webupd8team/java && apt-get -qq update

RUN echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections

RUN apt-get -qqy install oracle-java7-installer oracle-java6-installer

RUN apt-get -qqy install subversion

RUN wget -q -O - http://pkg.jenkins-ci.org/debian-stable/jenkins-ci.org.key | sudo apt-key add -
RUN echo deb http://pkg.jenkins-ci.org/debian binary/ >> /etc/apt/sources.list
RUN apt-get update && apt-get install -y jenkins ttf-freefont python
RUN mkdir -p /var/jenkins_home && chown -R jenkins /var/jenkins_home
ADD init.groovy /tmp/WEB-INF/init.groovy
RUN cd /tmp && zip -g /usr/share/jenkins/jenkins.war WEB-INF/init.groovy
ADD ./jenkins.sh /usr/local/bin/jenkins.sh
RUN chmod +x /usr/local/bin/jenkins.sh
USER jenkins

# VOLUME /var/jenkins_home - bind this in via -v if you want to make this persistent.
ENV JENKINS_HOME /var/jenkins_home

VOLUME ["/var/jenkins_home"]

# define url prefix for running jenkins behind Apache (https://wiki.jenkins-ci.org/display/JENKINS/Running+Jenkins+behind+Apache)
ENV JENKINS_PREFIX /jenkins

ENV MAVEN_HOME /usr/lib/maven2/

# for main web interface:
EXPOSE 8080 

# will be used by attached slave agents:
EXPOSE 50000 

CMD ["/usr/local/bin/jenkins.sh"]

# base image
FROM java:8
MAINTAINER Krishna.Manchikalapudi@gmail.com

# variables
ENV JMETER_BINARY apache-jmeter-5.1.1

RUN wget "http://mirrors.ocf.berkeley.edu/apache/jmeter/binaries/apache-jmeter-5.1.1.tgz"
RUN tar -xvzf apache-jmeter-5.1.1.tgz
RUN mv apache-jmeter-5.1.1 /jmeter

ENV JMETER_HOME /jmeter

# Add Jmeter to the Path
ENV PATH $JMETER_HOME/bin:$PATH
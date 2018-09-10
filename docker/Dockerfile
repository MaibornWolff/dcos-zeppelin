FROM mesosphere/spark:2.3.1-2.2.1-2-hadoop-2.6

ARG SPARK_VERSION=2.3.1-2.2.1-2-hadoop-2.6
ARG ZEPPELIN_VERSION=0.8.1-SNAPSHOT

ENV DEBIAN_FRONTEND noninteractive
RUN echo "deb http://ftp.gwdg.de/pub/misc/cran/bin/linux/ubuntu trusty/" >> /etc/apt/sources.list
RUN apt-get update && apt-get install --yes --force-yes -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" software-properties-common wget tar r-base libssl-dev libcurl4-openssl-dev

# Prepare python
RUN wget https://bootstrap.pypa.io/get-pip.py && python2 get-pip.py && python3 get-pip.py && rm get-pip.py

# Prepare R
RUN R -e "install.packages('devtools', repos = 'http://cran.us.r-project.org')" && \
R -e "install.packages('knitr', repos = 'http://cran.us.r-project.org')" && \
R -e "install.packages('ggplot2', repos = 'http://cran.us.r-project.org')" && \
R -e "install.packages(c('mplot', 'googleVis'), repos = 'http://cran.us.r-project.org'); require(devtools); install_github('ramnathv/rCharts')"


# hadoop config
ENV HADOOP_CONF_DIR /etc/hadoop/conf/
RUN mkdir -p $HADOOP_CONF_DIR

# zeppelin
ENV SPARK_MESOS_EXECUTOR_DOCKER_IMAGE mesosphere/spark:$SPARK_VERSION
WORKDIR /
COPY zeppelin.tgz /
RUN tar xzvf zeppelin.tgz && rm zeppelin.tgz && mv zeppelin-$ZEPPELIN_VERSION zeppelin
WORKDIR /zeppelin
ADD zeppelin-env.sh conf/zeppelin-env.sh
ADD startup.sh bin/

CMD ["bin/startup.sh"]

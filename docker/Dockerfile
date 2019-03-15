ARG SPARK_VERSION=2.7.0-2.4.0-hadoop-2.7
FROM mesosphere/spark:$SPARK_VERSION

ARG ZEPPELIN_VERSION=0.8.1
ARG PACKAGE_TYPE=all

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
RUN wget -q -O zeppelin.tgz "http://www.apache.org/dyn/closer.cgi?action=download&filename=/zeppelin/zeppelin-$ZEPPELIN_VERSION/zeppelin-$ZEPPELIN_VERSION-bin-$PACKAGE_TYPE.tgz"
RUN tar xzvf zeppelin.tgz && rm zeppelin.tgz && mv zeppelin-$ZEPPELIN_VERSION-bin-$PACKAGE_TYPE zeppelin
WORKDIR /zeppelin
ADD zeppelin-env.sh conf/zeppelin-env.sh
ADD startup.sh bin/

CMD ["bin/startup.sh"]

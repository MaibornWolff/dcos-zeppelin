ARG SPARK_VERSION=2.1.0-2.2.1-1-hadoop-2.6
FROM mesosphere/spark:$SPARK_VERSION

ARG SPARK_VERSION
ARG ZEPPELIN_VERSION
ARG PACKAGE_TYPE=all

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install --yes software-properties-common wget tar

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

#!/bin/bash

ZEPPELIN_CONFIG_OPTION=""
CONF_DIR="conf"
if [ -n "$ZEPPELIN_DATA_VOLUME" ]; then
  mkdir -p $ZEPPELIN_DATA_VOLUME/config
  cp conf/log4j.properties conf/zeppelin-env.sh $ZEPPELIN_DATA_VOLUME/config
  ZEPPELIN_CONFIG_OPTION="--config $ZEPPELIN_DATA_VOLUME/config"
  CONF_DIR="$ZEPPELIN_DATA_VOLUME/config"
fi

if [ -f "$MESOS_SANDBOX/zeppelin-site.xml" ]; then
  cp $MESOS_SANDBOX/zeppelin-site.xml $CONF_DIR/zeppelin-site.xml
else
  cp conf/zeppelin-site.xml.template $CONF_DIR/zeppelin-site.xml
fi
sed -i'' "s#<value>8080</value>#<value>$PORT0</value>#" $CONF_DIR/zeppelin-site.xml

if [ -f "${MESOS_SANDBOX}/hdfs-site.xml" ]; then
  cp "${MESOS_SANDBOX}/hdfs-site.xml" "${HADOOP_CONF_DIR}"
fi
if [ -f "${MESOS_SANDBOX}/core-site.xml" ]; then
  cp "${MESOS_SANDBOX}/core-site.xml" "${HADOOP_CONF_DIR}"
fi

if [ -f "$MESOS_SANDBOX/shiro.ini" ]; then
  cp $MESOS_SANDBOX/shiro.ini $CONF_DIR/shiro.ini
elif [ "$ZEPPELIN_SHIRO_CONF" != "" ]; then
  echo "$ZEPPELIN_SHIRO_CONF" > $CONF_DIR/shiro.ini
fi

SPARK_HOME=/opt/spark/dist bin/zeppelin.sh $ZEPPELIN_CONFIG_OPTION start

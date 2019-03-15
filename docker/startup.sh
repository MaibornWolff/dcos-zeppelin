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

# Install extra python packages
if [ -n "$PYTHON_PACKAGES" ]; then
  if [ -n "$PIP_PATH" ]; then
    $PIP_PATH install $PYTHON_PACKAGES
  elif [[ $PYSPARK_PYTHON == python3* ]]; then
    pip3 install $PYTHON_PACKAGES
  else
    pip2 install $PYTHON_PACKAGES
  fi
fi

# Install extra r packages
if [ -n "$R_PACKAGES" ]; then
  R -e "install.packages($R_PACKAGES, repos = 'http://cran.us.r-project.org')"
fi

# Install custom cacerts
if [ -e /mnt/mesos/sandbox/cacerts ]; then
	find /usr/lib/jvm -name cacerts -exec cp /mnt/mesos/sandbox/cacerts '{}' \; 
fi

# Add custom jars 
if [ -e /mnt/mesos/sandbox/jars ]; then
    cp /mnt/mesos/sandbox/*jar /opt/spark/dist/jars/
    cp /mnt/mesos/sandbox/*jar /zeppelin/lib/
fi

SPARK_HOME=/opt/spark/dist bin/zeppelin.sh $ZEPPELIN_CONFIG_OPTION start

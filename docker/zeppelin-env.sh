export ZEPPELIN_JAVA_OPTS="${ZEPPELIN_JAVA_OPTS} -Dspark.mesos.coarse=true -Dspark.mesos.executor.home=/opt/spark/dist"
export ZEPPELIN_INTP_JAVA_OPTS="${ZEPPELIN_INTP_JAVA_OPTS} -Dspark.mesos.coarse=true -Dspark.mesos.executor.home=/opt/spark/dist"

if [ -n "${SPARK_MESOS_EXECUTOR_DOCKER_IMAGE}" ]; then
  export ZEPPELIN_JAVA_OPTS="${ZEPPELIN_JAVA_OPTS} -Dspark.mesos.executor.docker.image=${SPARK_MESOS_EXECUTOR_DOCKER_IMAGE}"
  export ZEPPELIN_INTP_JAVA_OPTS="${ZEPPELIN_INTP_JAVA_OPTS} -Dspark.mesos.executor.docker.image=${SPARK_MESOS_EXECUTOR_DOCKER_IMAGE}"
fi

if [ -n "${SPARK_EXECUTOR_MEMORY}" ]; then
  export ZEPPELIN_JAVA_OPTS="${ZEPPELIN_JAVA_OPTS} -Dspark.executor.memory=${SPARK_EXECUTOR_MEMORY}"
  export ZEPPELIN_INTP_JAVA_OPTS="${ZEPPELIN_INTP_JAVA_OPTS} -Dspark.executor.memory=${SPARK_EXECUTOR_MEMORY}"
fi

if [ -n "${SPARK_CORES_MAX}" ]; then
  export ZEPPELIN_JAVA_OPTS="${ZEPPELIN_JAVA_OPTS} -Dspark.cores.max=${SPARK_CORES_MAX}"
  export ZEPPELIN_INTP_JAVA_OPTS="${ZEPPELIN_INTP_JAVA_OPTS} -Dspark.cores.max=${SPARK_CORES_MAX}"
fi

if [ -n "${SPARK_EXECUTOR_CORES}" ]; then
  export ZEPPELIN_JAVA_OPTS="${ZEPPELIN_JAVA_OPTS} -Dspark.executor.cores=${SPARK_EXECUTOR_CORES}"
  export ZEPPELIN_INTP_JAVA_OPTS="${ZEPPELIN_INTP_JAVA_OPTS} -Dspark.executor.cores=${SPARK_EXECUTOR_CORES}"
fi

if [ -n "${SPARK_MESOS_EXECUTOR_DOCKER_VOLUMES}" ]; then
  export ZEPPELIN_JAVA_OPTS="${ZEPPELIN_JAVA_OPTS} -Dspark.mesos.executor.docker.volumes=${SPARK_MESOS_EXECUTOR_DOCKER_VOLUMES}"
  export ZEPPELIN_INTP_JAVA_OPTS="${ZEPPELIN_INTP_JAVA_OPTS} -Dspark.mesos.executor.docker.volumes=${SPARK_MESOS_EXECUTOR_DOCKER_VOLUMES}"
fi

export MASTER=mesos://zk://master.mesos:2181/mesos
export MESOS_NATIVE_LIBRARY=/usr/lib/libmesos.so

# Zeppelin on DC/OS

This project provides docker images and marathon app definitions to run [Apache Zeppelin](https://zeppelin.apache.org/) on [DC/OS](https://dcos.io). Images are published to [Docker Hub](https://hub.docker.com/r/maibornwolff/zeppelin/).

This is a custom-built image based on the mesosphere spark docker image because the official Zeppelin docker image does not contain the neccessary libraries for mesos and can not be configured for the extra features that are possible with DC/OS (see below).

This project is also available as a DC/OS [universe package](https://universe.dcos.io/#/package/zeppelin/version/latest). Install it using `dcos package install zeppelin`.

**The Spark interpreter in Zeppelin can currently not be used on a DC/OS EE cluster with strict security mode enabled.**
Please use a cluster configured with disabled or permissive security mode.


## Build image with custom-built zeppelin
1. Fork apache/zeppelin project, make your changes and build project using maven.
2. Copy the resulting dist tar into the docker directory as `zeppelin.tgz`
3. Run `./build.sh` to build docker image
4. Push to your private registry
5. Use one of the marathon app definitions and change the docker image name to your custom image


## Quickstart
1. `dcos marathon app add deploy/zeppelin-minimal.json`
2. Open the DC/OS UI
3. Wait till the zeppelin service is green / healthy
4. use the "Open Service" link to open zeppelin in a new tab


## How to install
1. Use the marathon app definition in deploy/zeppelin-minimal.json as a basis
2. Choose the extra features you want from the list below and modify the json accordingly or use extended zeppelin-volume-shiro-hdfs.json file
3. Choose a image variant based on spark version
4. If you use another spark version than the default, don't forget to change the environment variable `SPARK_MESOS_EXECUTOR_DOCKER_IMAGE`
5. Change `SPARK_CORES_MAX` and `SPARK_EXECUTOR_MEMORY` depending on your cluster size and available resources
6. Deploy to marathon


### Requirements
* DC/OS 1.10 or 1.11 (OpenSource or Enterprise)
* Optional: HDFS
* Optional: Marathon-LB
* Optional: HTTP Fileserver


## Features

### Persistent Notebooks
The docker image is built to store notebook data on a persistent volume. To use it add a volume definition to the app
```json
{
  "container": {
    "volumes": [
      {
        "containerPath": "/zeppelin-data",
        "external": {
          "name": "volume-zeppelin-data",
          "provider": "dvdi",
          "options": {
            "dvdi/driver": "rexray"
          }
        },
        "mode": "RW"
      }
    ]
  }
}
```
and set the following environment variables:
* Set `ZEPPELIN_DATA_VOLUME` to the mount path of the volume (e.g. `/zeppelin-data`)
* Set `ZEPPELIN_NOTEBOOK_DIR` to a subpath of the volume (e.g. `/zeppelin-data/notebook`)

It is recommended to use an external persistent volume so that data is not lost even when a node breaks down.

### User Management
For authentication and authorization Zeppelin uses [Shiro](https://zeppelin.apache.org/docs/0.7.3/security/shiroauthentication.html). It is configured using a file `shiro.ini`. The docker image searches for this file in the sandbox directory on startup. You can provide it either via the fetch file mechanism or as a secret (recommended, only available on DC/OS EE).

To use a secret execute the following steps:
1. Create your custom shiro.ini file, there is an example file in the deploy folder in this repo.
2. Create a secret from this file using the dcos cli: `dcos security secrets create -f shiro.ini zeppelin/shiro-conf`
3. Add a secrets definition to the app:
  ```json
  {
    "secrets": {
      "shiroconf": {
        "source": "zeppelin/shiro-conf"
      }
    }
  }
  ```
4. Provide secret as an environment variable
```json
{
  "env": {
    "ZEPPELIN_SHIRO_CONF": {
      "secret": "shiroconf"
    }
  }
}
```

To use the fetch file mechanism:
1. Create your custom shiro.ini file, there is an example file in the deploy folder in this repo.
2. Upload your shiro.ini file to a location accessible via http from your cluster.
3. Add a fetch definition to your app:
```json
{
  "fetch": [
    {"uri": "http://my.fileserver/zeppelin/shiro.ini", "extract": false, "executable": false, "cache": false }
  ]
}
```

### HDFS
To access HDFS from zeppelin you need to provide the files `hdfs-site.xml` and `core-site.xml`. if you installed the HDFS framework from the Universe, you just need to add the following fetch definition to the app:
```json
{
  "fetch": [
    { "uri": "http://api.hdfs.marathon.l4lb.thisdcos.directory/v1/endpoints/hdfs-site.xml", "extract": false, "executable": false, "cache": false },
    { "uri": "http://api.hdfs.marathon.l4lb.thisdcos.directory/v1/endpoints/core-site.xml", "extract": false, "executable": false, "cache": false }
  ]
}
```

### External executor volume

Set the list of volumes which will be mounted into the Docker image, which was set using spark.mesos.executor.docker.image. The format of this property is a comma-separated list of mappings following the form passed to docker run -v. Define an `ENV` variable

```
SPARK_MESOS_EXECUTOR_DOCKER_VOLUMES="[host_path:]container_path[:ro|:rw]"
```
e.g.:
```
SPARK_MESOS_EXECUTOR_DOCKER_VOLUMES="/mnt/share/data:/data:rw"
```


### Extra configuration
You can provide your own custom zeppelin-site.xml:
1. Create your custom zeppelin-site.xml
2. Make sure not to change the default bind port for zeppelin (8080) as on startup this will be replaced with the host port of the container
3. Upload your zeppelin-site.xml file to a location accessible via http from your cluster.
4. Add a fetch definition to your app:
```json
{
  "fetch": [
    {"uri": "http://my.fileserver/zeppelin/zeppelin-site.xml", "extract": false, "executable": false, "cache": false }
  ]
}
```

### Python support
The docker image contains python2.7 and python3.4. You can use the python and pyspark interpreters without further configuration.
By default python2.7 is used, if you want to use python3.4 set the environment variable `PYSPARK_PYTHON` to `python3`.
You can also install additional python packages at startup. To do that set the environment variable `PYTHON_PACKAGES` to a space-separated list of packages (for example `PYTHON_PACKAGES="requests tensorflow"`). This list will be given to pip at startup. Be aware that installing packages increases the startup time of zeppelin.


### R support
The docker image contains R version 3.4 and already has the recommended packages from the [Zeppelin documentation](https://zeppelin.apache.org/docs/0.7.3/interpreter/r.html) installed, specifically `devtools`, `knitr`, `ggplot2`, `mplot` and `googleVis`. You can install additional R packages at startup by setting the environment variable `R_PACKAGES`. The content of this variable will be fed directly to `install.packages()`, so be sure to use the correct syntax (e.g. `R_PACKAGES="c('glmnet', 'caret')"`). Be aware that installing packages can drastically increase the startup time of zeppelin.


### External access
The provided marathon app definition by default allows access to zeppelin via the admin router proxy ("Open Service" in the DC/OS UI). if you have marathon-lb installed you can also use it. Just add the following labels to the app:
```json
{
  "labels": {
    "HAPROXY_GROUP": "external",
    "HAPROXY_0_VHOST": "zeppelin.my.domain"
  },
}
```


### Interpreters
There are two variants of the docker image based on the download variants on the zeppelin homepage:
* all: With all interpeters
* netinst: With only the spark interpreter

By default the app definitions use the all variant. If you want the netinst variant, just change the `-all` in the docker image tag to `-netinst`.


## Building
```bash
./build.sh
```

The build script will build docker images with zeppelin with all interpreters (all) or just the spark interpreter (netinst).


## Acknowledgments
This project is based on the official [mesosphere spark docker image](https://hub.docker.com/r/mesosphere/spark/tags/).


## Contributing
If you find a bug or have a feature request, just open an issue in Github. Or, if you want to contribute something, feel free to open a pull request.

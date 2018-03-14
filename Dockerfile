
FROM java:8


ENV hadoop_ver 2.6.1
ENV spark_ver 1.6.2

# Get Hadoop from US Apache mirror and extract just the native
# libs. (Until we care about running HDFS with these containers, this
# is all we need.)
RUN mkdir -p /opt && \
    cd /opt && \
    curl http://mirrors.aliyun.com/apache/hadoop/common/hadoop-${hadoop_ver}/hadoop-${hadoop_ver}.tar.gz | \
        tar -zx hadoop-${hadoop_ver}/lib/native && \
    ln -s hadoop-${hadoop_ver} hadoop && \
    echo Hadoop ${hadoop_ver} native libraries installed in /opt/hadoop/lib/native

# Get Spark from US Apache mirror.
RUN mkdir -p /opt && \
    cd /opt && \
    curl http://mirrors.aliyun.com/apache/spark/spark-${spark_ver}/spark-${spark_ver}-bin-hadoop2.6.tgz | \
        tar -zx && \
    ln -s spark-${spark_ver}-bin-hadoop2.6 spark && \
    echo Spark ${spark_ver} installed in /opt

# Add the GCS connector.
#RUN cd /opt/spark/lib && \
#    curl -O https://storage.googleapis.com/hadoop-lib/gcs/gcs-connector-latest-hadoop2.jar

# if numpy is installed on a driver it needs to be installed on all
# workers, so install it everywhere

RUN sed -i "s/http:\/\/httpredir.debian.org/http:\/\/mirrors.aliyun.com/g" /etc/apt/sources.list && \
    sed -i "s/http:\/\/security.debian.org/http:\/\/mirrors.aliyun.com\/debian-security/g" /etc/apt/sources.list
RUN apt-get update && \
    apt-get install -y python-numpy && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ADD log4j.properties /opt/spark/conf/log4j.properties
ADD start-common.sh start-worker start-master /
ADD core-site.xml /opt/spark/conf/core-site.xml
ADD spark-defaults.conf /opt/spark/conf/spark-defaults.conf
ENV PATH $PATH:/opt/spark/bin


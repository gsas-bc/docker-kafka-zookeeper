# Kafka and Zookeeper

FROM java:openjdk-8-jre

ENV DEBIAN_FRONTEND noninteractive

RUN echo "deb [check-valid-until=no] http://cdn-fastly.deb.debian.org/debian jessie main" > /etc/apt/sources.list.d/jessie.list
RUN echo "deb [check-valid-until=no] http://archive.debian.org/debian jessie-backports main" > /etc/apt/sources.list.d/jessie-backports.list
RUN sed -i '/deb http:\/\/deb.debian.org\/debian jessie-updates main/d' /etc/apt/sources.list
RUN apt-get -o Acquire::Check-Valid-Until=false update

RUN apt-get install -y wget supervisor && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean


ENV ZOOKEEPER_VERSION 3.4.12
ENV ZOOKEEPER_HOME /opt/zookeeper-"$ZOOKEEPER_VERSION"

RUN wget -q http://archive.apache.org/dist/zookeeper/zookeeper-$ZOOKEEPER_VERSION/zookeeper-$ZOOKEEPER_VERSION.tar.gz -O /tmp/zookeeper-$ZOOKEEPER_VERSION.tgz
RUN ls -l /tmp/zookeeper-"$ZOOKEEPER_VERSION".tgz
RUN tar xfz /tmp/zookeeper-"$ZOOKEEPER_VERSION".tgz -C /opt && rm /tmp/zookeeper-"$ZOOKEEPER_VERSION".tgz
ADD assets/conf/zoo.cfg $ZOOKEEPER_HOME/conf

ENV SCALA_VERSION 2.12
ENV KAFKA_VERSION 1.1.0
ENV KAFKA_HOME /opt/kafka_"$SCALA_VERSION"-"$KAFKA_VERSION"
ENV KAFKA_DOWNLOAD_URL https://archive.apache.org/dist/kafka/$KAFKA_VERSION/kafka_$SCALA_VERSION-$KAFKA_VERSION.tgz

RUN wget -q $KAFKA_DOWNLOAD_URL -O /tmp/kafka_"$SCALA_VERSION"-"$KAFKA_VERSION".tgz
RUN tar xfz /tmp/kafka_"$SCALA_VERSION"-"$KAFKA_VERSION".tgz -C /opt && rm /tmp/kafka_"$SCALA_VERSION"-"$KAFKA_VERSION".tgz

ADD assets/scripts/start-kafka.sh /usr/bin/start-kafka.sh
ADD assets/scripts/start-zookeeper.sh /usr/bin/start-zookeeper.sh

# Supervisor config
ADD assets/supervisor/kafka.conf assets/supervisor/zookeeper.conf /etc/supervisor/conf.d/

# 2181 is zookeeper, 9092 is kafka
EXPOSE 2181 9092

CMD ["supervisord", "-n"]

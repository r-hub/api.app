
FROM docker.elastic.co/elasticsearch/elasticsearch:6.8.19

COPY synonyms.txt /usr/share/elasticsearch/config/synonyms.txt

RUN echo "discovery.type: single-node" >> /usr/share/elasticsearch/config/elasticsearch.yml

RUN yum -y install zip
RUN zip -q -d /usr/share/elasticsearch/lib/log4j-core-2.11.1.jar org/apache/logging/log4j/core/lookup/JndiLookup.class

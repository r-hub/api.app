
FROM docker.elastic.co/logstash/logstash:6.8.20

RUN logstash-plugin install logstash-input-couchdb_changes
RUN logstash-plugin install logstash-filter-ruby

COPY logstash.conf /usr/share/logstash/config/logstash.conf
COPY crandb-filter.rb /usr/share/logstash/config/crandb-filter.rb

USER root

RUN yum -y install zip
RUN zip -q -d /usr/share/logstash/logstash-core/lib/jars/log4j-core-2.9.1.jar  org/apache/logging/log4j/core/lookup/JndiLookup.class

USER logstash

CMD ["-f", "/usr/share/logstash/config/logstash.conf"]

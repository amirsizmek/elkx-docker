# Dockerfile for ELK stack with X-Pack
# Elasticsearch, Logstash, Kibana, X-Pack 6.2.3

# Build with:
# docker build -t <repo-user>/elkx .

# Run with:
# docker run -p 5601:5601 -p 9200:9200 -p 5044:5044 -it --name elk <repo-user>/elkx

FROM sebp/elk:623
MAINTAINER Sebastien Pujadas http://pujadas.net
ENV REFRESHED_AT 2017-05-10

###############################################################################
#                                INSTALLATION
###############################################################################

ENV XPACK_VERSION 6.2.3
ENV XPACK_PACKAGE x-pack-${XPACK_VERSION}.zip

WORKDIR /tmp
RUN curl -O https://artifacts.elastic.co/downloads/packs/x-pack/${XPACK_PACKAGE} \
 && gosu elasticsearch ${ES_HOME}/bin/elasticsearch-plugin install \
      -Edefault.path.conf=/etc/elasticsearch \
      file:///tmp/${XPACK_PACKAGE} --batch \
 && gosu kibana ${KIBANA_HOME}/bin/kibana-plugin install \
      file:///tmp/${XPACK_PACKAGE} \
 && gosu logstash ${LOGSTASH_HOME}/bin/logstash-plugin install --local \
      file:///tmp/${XPACK_PACKAGE} \
 && rm -f ${XPACK_PACKAGE}

###############################################################################
#                                KIBANA PLUGINS
###############################################################################
RUN /opt/kibana/bin/kibana-plugin install https://github.com/sirensolutions/sentinl/releases/download/tag-6.2.3/sentinl-v6.2.3.zip


###############################################################################
#                               CONFIGURATION
###############################################################################

### configure Logstash

ADD ./30-output.conf /etc/logstash/conf.d/30-output.conf


###############################################################################
#                                   START
###############################################################################

ADD ./startx.sh /usr/local/bin/startx.sh
RUN chmod +x /usr/local/bin/startx.sh

CMD [ "/usr/local/bin/startx.sh" ]

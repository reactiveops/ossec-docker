FROM centos:latest
MAINTAINER Support <support@atomicorp.com>

RUN cd /root && \
  yum -y update && \
  yum -y install wget useradd postfix && \
  NON_INT=1 wget -q -O - https://updates.atomicorp.com/installers/atomic | sh && \
  yum -y install ossec-hids-server && \
  yum clean all && \
  rm -rf /var/cache/yum/

ADD default_agent /var/ossec/default_agent

# copy base config
ADD ossec.conf /var/ossec/etc/

#
# Initialize the data volume configuration
#
ADD data_dirs.env /data_dirs.env
ADD init.sh /init.sh
# Sync calls are due to https://github.com/docker/docker/issues/9547
RUN chmod 755 /init.sh &&\
  sync && /init.sh &&\
  sync && rm /init.sh

#
# Add the bootstrap script
#
ADD ossec-server.sh /ossec-server.sh
RUN chmod 755 /ossec-server.sh

#
# Specify the data volume
#
VOLUME ["/var/ossec/data"]

# Expose ports for sharing
EXPOSE 1514/udp 1515/tcp 514/tcp 514/udp

#
# Define default command.
#
ENTRYPOINT ["/ossec-server.sh"]

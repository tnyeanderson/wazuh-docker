FROM centos:7

ARG FILEBEAT_VERSION=7.4.2
ARG WAZUH_VERSION=3.10.2-1
ARG TEMPLATE_VERSION="v3.10.2"
ARG WAZUH_FILEBEAT_MODULE="wazuh-filebeat-0.1.tar.gz"

ENV API_USER="foo" \
   API_PASS="bar"


# Set repositories.
RUN rpm --import https://packages.wazuh.com/key/GPG-KEY-WAZUH

COPY config/wazuh.repo /etc/yum.repos.d/wazuh.repo

RUN yum --enablerepo=updates clean metadata && \
  yum -y update && yum -y install openssl && yum -y install wazuh-manager-${WAZUH_VERSION} -y && yum clean all && rm -rf /var/cache/yum

RUN curl --silent --location https://rpm.nodesource.com/setup_8.x | bash - && \
  yum -y install nodejs && yum -y install wazuh-api-${WAZUH_VERSION} && \
  sed -i "s/^enabled=1/enabled=0/" /etc/yum.repos.d/wazuh.repo && \
  yum clean all && \
  rm -rf /var/cache/yum
  
RUN echo openssl_conf = openssl_conf_section > /etc/pki/tls/openssl.cnf && \
echo [openssl_conf_section] >> /etc/pki/tls/openssl.cnf && \
echo alg_section = evp_settings >> /etc/pki/tls/openssl.cnf && \
echo [evp_settings] >> /etc/pki/tls/openssl.cnf && \
echo fips_mode = yes >> /etc/pki/tls/openssl.cnf

RUN curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-oss-${FILEBEAT_VERSION}-x86_64.rpm &&\
  rpm -i filebeat-oss-${FILEBEAT_VERSION}-x86_64.rpm && rm -f filebeat-oss-${FILEBEAT_VERSION}-x86_64.rpm

RUN curl -so /etc/filebeat/filebeat.yml https://raw.githubusercontent.com/wazuh/wazuh/${TEMPLATE_VERSION}/extensions/filebeat/7.x/filebeat.yml &&\
  chmod go+r /etc/filebeat/filebeat.yml

RUN curl -so /etc/filebeat/wazuh-template.json https://raw.githubusercontent.com/wazuh/wazuh/${TEMPLATE_VERSION}/extensions/elasticsearch/7.x/wazuh-template.json &&\
  chmod go+r /etc/filebeat/wazuh-template.json

RUN curl -s https://packages.wazuh.com/3.x/filebeat/${WAZUH_FILEBEAT_MODULE} | tar -xvz -C /usr/share/filebeat/module

RUN yum -y install epel-release && yum -y install htop && yum clean all && rm -rf /var/cache/yum

# Adding first run script and entrypoint
COPY config/data_dirs.env /data_dirs.env
COPY config/init.bash /init.bash
RUN mkdir /entrypoint-scripts
COPY config/entrypoint.sh /entrypoint.sh
COPY config/00-wazuh.sh config/01-config_filebeat.sh /entrypoint-scripts/


EXPOSE 55000/tcp 1514/udp 1515/tcp 514/udp 1516/tcp

# Sync calls are due to https://github.com/docker/docker/issues/9547
RUN chmod 755 /init.bash && \
   sync && /init.bash && \
   sync && rm /init.bash && \
   chmod 755 /entrypoint.sh && \
   chmod 755 /entrypoint-scripts/00-wazuh.sh && \
   chmod 755 /entrypoint-scripts/01-config_filebeat.sh

COPY config/filebeat.yml /etc/filebeat/
RUN chmod go-w /etc/filebeat/filebeat.yml


ENTRYPOINT ["/entrypoint.sh"]

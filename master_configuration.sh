#!/bin/bash
  
DIRECTORY="/var/ossec"
  
id=$(hostname -i | tr -d ".")
  
start_config="$(grep -n "<cluster>" ${DIRECTORY}/etc/ossec.conf | cut -d':' -f 1)"
end_config="$(grep -n "</cluster>" ${DIRECTORY}/etc/ossec.conf | cut -d':' -f 1)"
 
# remove previous configuration
sed -i "${start_config},${end_config}d" ${DIRECTORY}/etc/ossec.conf
 
# use any source for registration process
sed -i "s/<use_source_ip>yes/<use_source_ip>no/g" ${DIRECTORY}/etc/ossec.conf
 
  
cat >> ${DIRECTORY}/etc/ossec.conf <<- EOM
<ossec_config>
  <cluster>
    <name>wazuh</name>
    <node_name>WAZUH_MASTER</node_name>
    <node_type>master</node_type>
    <key>c98b62a9b6169ac5f67dae55ae4a9088</key>
    <port>1516</port>
    <bind_addr>0.0.0.0</bind_addr>
    <nodes>
        <node>wazuh</node>
    </nodes>
    <hidden>no</hidden>
    <disabled>no</disabled>
  </cluster>
 </ossec_config>
 
EOM

#!/bin/bash
  
DIRECTORY="/var/ossec"
  
id=$(hostname -i | tr -d ".")
  
start_config="$(grep -n "<cluster>" ${DIRECTORY}/etc/ossec.conf | cut -d':' -f 1)"
end_config="$(grep -n "</cluster>" ${DIRECTORY}/etc/ossec.conf | cut -d':' -f 1)"
 
sed -i "s/${client_config}//g" ${DIRECTORY}/etc/ossec.conf
  
cat >> ${DIRECTORY}/etc/ossec.conf <<- EOM
 <ossec_config>
   <cluster>
    <name>wazuh</name>
    <node_name>WAZUH_WORKER-NODENAME</node_name>
    <node_type>worker</node_type>
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
  
sed -i -e "s#NODENAME#${id}#g" ${DIRECTORY}/etc/ossec.conf

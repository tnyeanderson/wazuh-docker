#!/bin/bash

exit_script() {
    /var/ossec/bin/ossec-control stop
    trap - SIGINT SIGTERM # clear the trap
    kill -- -$$ # Sends SIGTERM to child/sub processes
}

trap exit_script SIGINT SIGTERM


# It will run every .sh script located in entrypoint-scripts folder in lexicographical order
for script in `ls /entrypoint-scripts/*.sh | sort -n`; do
  bash "$script"
done

/var/ossec/bin/ossec-control start &
/bin/node /var/ossec/api/app.js &
/usr/share/filebeat/bin/filebeat -e -c /etc/filebeat/filebeat.yml -path.home /usr/share/filebeat -path.config /etc/filebeat -path.data /var/lib/filebeat -path.logs /var/log/filebeat &

tail -f /var/ossec/logs/ossec.log &

wait %2 %3

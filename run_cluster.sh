#!/bin/bash
 
function clean_up {

    # Perform program exit housekeeping
    kill $CHILD_PID
    exit
}

trap clean_up SIGHUP SIGINT SIGTERM

rm -f nginx.conf

cp nginx_default.conf nginx.conf

docker-compose up --scale wazuh-worker=$1 --scale load-balancer=0 > services.logs &

CHILD_PID=$!

echo "Waiting for services start."

sleep 10

echo "Creating load-balancer configuration"
 
MASTER_IP=$(docker-compose exec wazuh hostname -i  )
 
sed -i -e "s#<WAZUH-MASTER-IP>#${MASTER_IP::-1}#g" nginx.conf
 
 
for i in $(seq 1 $1)
do
    WORKER_IP=$(docker-compose exec --index=$i wazuh-worker hostname -i)
    sed -i -e "s#NEXT_SERVER#server ${WORKER_IP::-1}:1514;\n\tNEXT_SERVER#g" nginx.conf
done
 
sed -i -e "s#NEXT_SERVER##g" nginx.conf
 
echo "Running load-balancer service"

docker-compose up load-balancer > load-balancer.logs 

wait $CHILD_PID


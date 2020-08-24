#!/bin/bash

#로그 시간 남김.
TIME=`date +"%Y-%m-%d_%H:%M:%S"`

#시스템의 IP 가져오기.
INET=`/sbin/ifconfig eth0 | /bin/awk '/inet/ {sub(/addr:/,"",$2); print $2}'`

PORT="5000"

#Redis Path
PATH='/srv/redis/'

#Redis Execute
SERVER=${PATH}'bin/redis-server'
CLIENT=${PATH}'bin/redis-cli'

#Redis Configuration
CONF='/redis.conf'

LOGFILES='/backup/log/detect_pcluster.log'

echo -e "\n"[${TIME}]" Detected Cluster\n " >> ${LOGFILES}
	
PING=`${CLIENT} -c -h ${INET} -p ${PORT} PING 2> /dev/null`
	
if [ -z ${PING} ]; then
	echo -e [${TIME}]">>> SHUTDOWN "${INET}":"${PORT} >> ${LOGFILES} 
	`${SERVER} ${PATH}${PORT}${CONF}`
	echo -e [${TIME}]">>> Restart "${INET}":"${PORT} >> ${LOGFILES}
fi

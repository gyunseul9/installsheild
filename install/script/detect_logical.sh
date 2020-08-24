#!/bin/bash

#로그 시간 남김.
TIME=`date +"%Y-%m-%d_%H:%M:%S"`

#시스템의 IP 가져오기.
INET=`/sbin/ifconfig eth0 | /bin/awk '/inet/ {sub(/addr:/,"",$2); print $2}'`

PORT=("5000" "6000" "7000")	
SIZE=${#PORT[@]}

#Redis Path
PATH='/srv/redis/'

#Redis Execute
SERVER=${PATH}'bin/redis-server'
CLIENT=${PATH}'bin/redis-cli'

#Redis Configuration
CONF='/redis.conf'

LOGFILES='/backup/log/detect_lcluster.log'

echo -e "\n"[${TIME}]" Detected Cluster\n " >> ${LOGFILES}

INCR=0

while [ ${INCR} -lt ${SIZE} ]
do
				
	echo -e [${TIME}]" Port : "${PORT[INCR]} >> ${LOGFILES}

	PING=`${CLIENT} -c -h ${INET} -p ${PORT[INCR]} PING 2> /dev/null`
		
	if [ -z ${PING} ]; then
		echo -e [${TIME}]">>> SHUTDOWN "${INET}":"${PORT[INCR]} >> ${LOGFILES} 
		`${SERVER} ${PATH}${PORT[INCR]}${CONF}`
		echo -e [${TIME}]">>> Restart "${INET}":"${PORT[INCR]} >> ${LOGFILES}
	fi
				
	INCR=`/usr/bin/expr ${INCR} + 1`
				
done
	


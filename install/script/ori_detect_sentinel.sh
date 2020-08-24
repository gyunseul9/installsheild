#!/bin/bash

#로그 시간 남김.
TIME=`date +"%Y-%m-%d_%H:%M:%S"`

LOGFILES='/backup/log/detect_sentinel.log'

#센티널 실행 시작 로그로 남김.
echo -e "\n"[${TIME}]" Run Scheduler\n " >> ${LOGFILES}

#센티널 프로세스 리턴. 
pid_sentinel=`ps -ef | grep '9000' | grep 'redis-sentinel' | grep -v 'grep' | awk '{print $2}'`

#센티널 프로세스가 없을 경우. 
if [ -z $pid_sentinel ]; then

	####센티널 프로세스 없음.
	echo -e [${TIME}]" Sentinel(9000) is None " >> ${LOGFILES}	
	
	####센티널 프로세스 실행.
	echo -e [${TIME}]" Start Sentinel(9000) " >> ${LOGFILES}
	/srv/redis/bin/redis-sentinel /srv/redis/9000/sentinel.conf
	
	####마스터 프로세스, 슬레이브 프로세스 종료 후 시작.
	
	####마스터 프로세스 리턴.
	pid_master=`ps -ef | grep '8000' | grep 'redis-server' | grep -v 'grep' | awk '{print $2}'`
	
	####마스터 프로세스가 없으면 마스터 프로세스 실행.
	if [ -z $pid_master ]; then
		echo -e [${TIME}]" Start Master(8000) " >> ${LOGFILES}
		/srv/redis/bin/redis-server /srv/redis/8000/redis.conf
	####마스터 프로세스가 있으면 마스터 프로세스 종료 후 실행.
	else
		echo -e [${TIME}]" Stop Master(8000) " >> ${LOGFILES}
		/srv/redis/bin/redis-cli -p 8000 -a 0123456789 SHUTDOWN	
		echo -e [${TIME}]" Start Master(8000) " >> ${LOGFILES}
		/srv/redis/bin/redis-server /srv/redis/8000/redis.conf		
	fi	
	
	sleep 5
	
	####슬레이브 프로세스 리턴.
	pid_slave=`ps -ef | grep '8010' | grep 'redis-server' | grep -v 'grep' | awk '{print $2}'`
	
	####슬레이브 프로세스가 없으면 슬레이브 프로세스 실행.
	if [ -z $pid_slave ]; then
		echo -e [${TIME}]" Start Slave(8010) " >> ${LOGFILES}
		/srv/redis/bin/redis-server /srv/redis/8010/redis.conf
	####슬레이브 프로세스가 있으면 슬레이브 프로세스 종료 후 실행.
	else
		echo -e [${TIME}]" Stop Slave(8010) " >> ${LOGFILES}
		/srv/redis/bin/redis-cli -p 8010 -a 0123456789 SHUTDOWN	
		echo -e [${TIME}]" Start Slave(8010) " >> ${LOGFILES}
		/srv/redis/bin/redis-server /srv/redis/8010/redis.conf		
	fi		
	
#센티널 프로세스가 있을 경우. 
else 	
	####센티널 프로세스 있음. 
	echo -e [${TIME}]" Sentinel(9000) is Exit " >> ${LOGFILES}	
	
	####마스터 프로세스 리턴.
	pid_master=`ps -ef | grep '8000' | grep 'redis-server' | grep -v 'grep' | awk '{print $2}'`	
	
	####슬레이브 프로세스 리턴.
	pid_slave=`ps -ef | grep '8010' | grep 'redis-server' | grep -v 'grep' | awk '{print $2}'`		
	
	####마스터 프로세스가 없다면.
	if [ -z $pid_master ]; then
	
		####마스터 프로세스 없다면. 
		echo -e [${TIME}]" Master(8000) is None " >> ${LOGFILES}		
	
		####슬레이브 프로세스가 없다면.
		if [ -z $pid_slave ]; then

			####슬레이브 프로세스가 없다면 마스터 프로세스, 슬레이브 프로세스 실행.
			echo -e [${TIME}]" Slave(8010) is None " >> ${LOGFILES}	
			echo -e [${TIME}]" Start Master(8000) " >> ${LOGFILES}
			/srv/redis/bin/redis-server /srv/redis/8000/redis.conf
			sleep 5		
			echo -e [${TIME}]" Start Slave(8010) " >> ${LOGFILES}
			/srv/redis/bin/redis-server /srv/redis/8010/redis.conf					

		else
		
			####슬레이브 프로세스가 있다면 마스터 프로세스 실행. 
			echo -e [${TIME}]" Slave(8010) is Exit " >> ${LOGFILES}			
			echo -e [${TIME}]" Start Master(8000) " >> ${LOGFILES}
			/srv/redis/bin/redis-server /srv/redis/8000/redis.conf				
		
		fi
	
	####마스터 프로세스가 있다면.
	else
		####마스터 프로세스가 있다면. 
		echo -e [${TIME}]" Master(8000) is Exist " >> ${LOGFILES}		
		
		####슬레이브 프로세스가 없다면.
		if [ -z $pid_slave ]; then
			echo -e [${TIME}]" Start Slave(8010) " >> ${LOGFILES}
			/srv/redis/bin/redis-server /srv/redis/8010/redis.conf				
		else
			echo -e [${TIME}]" Slave(8010) is Exist " >> ${LOGFILES}		
		fi		
		
	fi
	
fi


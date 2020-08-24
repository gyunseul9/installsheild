#!/bin/bash

#선행 		-> selinux 비활성, 방화벽 비활성.
#공통 		-> gcc 설치, sz/rz 설치, yum 설치.
#수집서버 		-> nodeJS 설치, redis 설치, shell 복사, crontab 등록, crond 재시작.
#집계서버 		-> php 설치, apache 설치, redis 설치, shell 복사, crontab 등록, crond 재시작.
#모니터서버	-> redis 설치, redis sentinel 설정, python 설치, redis-live 서비스 등록, shell 복사, crontab 등록, crond 재시작.
#수집클러스터	-> redis 설치, redis cluster 물리 설정, shell 복사, crontab 등록, crond 재시작, 클러스터 구성.
#집계클러스터	-> redis 설치, redis cluster 논리 설정, shell 복사, crontab 등록, crond 재시작, 클러스터 구성.
#외부클러스터	-> redis 설치, redis cluster 논리 설정, shell 복사, crontab 등록, crond 재시작, 클러스터 구성.

DATE=`date +"%Y%m%d"`
TIME=`date +"%Y-%m-%d %H:%M:%S"`

#시스템의 IP 가져오기.
INET=`/sbin/ifconfig eth0 | /bin/awk '/inet/ {sub(/addr:/,"",$2); print $2}'`

CHOOSE=${1}

LOGFILE=${CHOOSE}".log"

#명령어 선언.
YUM="/usr/bin/yum"
RPM="/bin/rpm"
CP="/bin/cp"
SED="/bin/sed"
MV="/bin/mv"
SERVICE="/sbin/service"
NPM="/usr/local/node/bin/npm"
RM="/bin/rm"
TAR="/bin/tar"
MAKE="/usr/bin/make"
MKDIR="/bin/mkdir"
LN="/bin/ln"
WGET="/usr/bin/wget"
UNZIP="/usr/bin/unzip"
PYTHON="/usr/bin/python"
PIP="/usr/bin/pip"
CHMOD="/bin/chmod"
GEM="/usr/bin/gem"

#크론탭 스크립트 경로. -> 테스트 후 실제 '/root/script' 경로로 변경.
SCRIPT_HOME="/root/script/"

#crontab 
CRONTAB="/etc/crontab"
#crontab 
CRONTMP="/etc/crontab_tmp"

#설치 스크립트 경로.
ORI_SCRIPT="/root/install/script"

#적용 스크립트 경로
DES_SCRIPT="/root/script"

#설치 환경설정 파일 경로.
ORI_CONFIG="/root/install/config"

#설치 소스 파일 경로.
ORI_SRC="/root/install/src"

#redis home
REDIS_HOME="/srv/redis"

##### collect:shell:start ######################################
#쉘스크립트 파일 배열 선언:설치:collect
ORI_COLLECT=("collect_backup_file.sh")
#쉘스크립트 파일 배열 선언:적용:collect
DES_COLLECT=("backup_file.sh")
#쉘스크립트 /etc/crontab 에 주석 적용:collect
CMT_COLLECT=("#collect backup files")
#쉘스크립트 /etc/crontab 에 스케줄 적용:collect
SCD_COLLECT=("0 4 @* @* @* root ${SCRIPT_HOME}")
#쉘스크립트 카운터:collect
SIZE_COLLECT=${#ORI_COLLECT[@]}
#### collect:shell:end #######################################

##### total:shell:start ######################################
#쉘스크립트 파일 배열 선언:설치:total
ORI_TOTAL=("total_backup_file.sh")
#쉘스크립트 파일 배열 선언:적용:total
DES_TOTAL=("backup_file.sh")
#쉘스크립트 /etc/crontab 에 주석 적용:total
CMT_TOTAL=("#total backup files")
#쉘스크립트 /etc/crontab 에 스케줄 적용:total
SCD_TOTAL=("0 4 @* @* @* root ${SCRIPT_HOME}")
#쉘스크립트 카운터:total
SIZE_TOTAL=${#ORI_TOTAL[@]}
#### collect:shell:end #######################################

##### monitor:shell:start ######################################
#쉘스크립트 파일 배열 선언:설치:monitor
ORI_MONITOR=("monitor_backup_file.sh" "detect_monitor.sh" "redis_monitor.sh")
#쉘스크립트 파일 배열 선언:적용:monitor
DES_MONITOR=("backup_file.sh" "detect_monitor.sh" "redis_monitor.sh")
#쉘스크립트 /etc/crontab 에 주석 적용:monitor
CMT_MONITOR=("#monitor backup files" "#monitor detect monitor" "#monitor redis monitor")
#쉘스크립트 /etc/crontab 에 스케줄 적용:monitor
SCD_MONITOR=("0 4 @* @* @* root ${SCRIPT_HOME}" "*/15 @* @* @* @* root ${SCRIPT_HOME}" "*/60 @* @* @* @* root ${SCRIPT_HOME}")
#쉘스크립트 카운터:monitor
SIZE_MONITOR=${#ORI_MONITOR[@]}
#### monitor:shell:end #######################################

##### p-cluster:shell:start ######################################
#쉘스크립트 파일 배열 선언:설치:p-cluster
ORI_PCLUSTER=("monitor_backup_file.sh" "detect_physical.sh")
#쉘스크립트 파일 배열 선언:적용:p-cluster
DES_PCLUSTER=("backup_file.sh" "detect_cluster.sh")
#쉘스크립트 /etc/crontab 에 주석 적용:p-cluster
CMT_PCLUSTER=("#p-cluster backup files" "#p-cluster detect cluster")
#쉘스크립트 /etc/crontab 에 스케줄 적용:p-cluster
SCD_PCLUSTER=("0 4 @* @* @* root ${SCRIPT_HOME}" "*/15 @* @* @* @* root ${SCRIPT_HOME}")
#쉘스크립트 카운터:p-cluster
SIZE_PCLUSTER=${#ORI_PCLUSTER[@]}
#### p-cluster:shell:end #######################################

##### l-cluster:shell:start ######################################
#쉘스크립트 파일 배열 선언:설치:l-cluster
ORI_LCLUSTER=("monitor_backup_file.sh" "detect_logical.sh")
#쉘스크립트 파일 배열 선언:적용:l-cluster
DES_LCLUSTER=("backup_file.sh" "detect_cluster.sh")
#쉘스크립트 /etc/crontab 에 주석 적용:l-cluster
CMT_LCLUSTER=("#l-cluster backup files" "#l-cluster detect cluster")
#쉘스크립트 /etc/crontab 에 스케줄 적용:l-cluster
SCD_LCLUSTER=("0 4 @* @* @* root ${SCRIPT_HOME}" "*/15 @* @* @* @* root ${SCRIPT_HOME}")
#쉘스크립트 카운터:l-cluster
SIZE_LCLUSTER=${#ORI_LCLUSTER[@]}
#### l-cluster:shell:end #######################################

##### test-cluster:shell:start ######################################
#쉘스크립트 파일 배열 선언:설치:test-cluster
ORI_TESTCLUSTER=("monitor_backup_file.sh" "detect_test.sh")
#쉘스크립트 파일 배열 선언:적용:test-cluster
DES_TESTCLUSTER=("backup_file.sh" "detect_cluster.sh")
#쉘스크립트 /etc/crontab 에 주석 적용:test-cluster
CMT_TESTCLUSTER=("#test-cluster backup files" "#test-cluster detect cluster")
#쉘스크립트 /etc/crontab 에 스케줄 적용:test-cluster
SCD_TESTCLUSTER=("0 4 @* @* @* root ${SCRIPT_HOME}" "*/15 @* @* @* @* root ${SCRIPT_HOME}")
#쉘스크립트 카운터:test-cluster
SIZE_TESTCLUSTER=${#ORI_TESTCLUSTER[@]}
#### test-cluster:shell:end #######################################

#함수선언:쉘스크립트
function shell(){
	
	local PARAMETER=${1}

	echo -e [${TIME}]" Start Shell" #>> ${LOGFILE}

	echo -e [${TIME}]" Parameter :"${PARAMETER} #>> ${LOGFILE}

	case ${PARAMETER} in
		#수집서버.
		"collect")
		
			echo -e [${TIME}]" Choose "${PARAMETER} #>> ${LOGFILE}

			INCR_COLLECT=0
			
			while [ ${INCR_COLLECT} -lt ${SIZE_COLLECT} ]
			do
				
				echo -e [${TIME}]" Copy script : "${ORI_COLLECT[INCR_COLLECT]} #>> ${LOGFILE}

				#스크립트 복사:설치->적용.
				${CP} ${ORI_SCRIPT}/${ORI_COLLECT[INCR_COLLECT]} ${DES_SCRIPT}/${DES_COLLECT[INCR_COLLECT]}
				
				echo ${CMT_COLLECT[INCR_COLLECT]} >> ${CRONTAB}
				
				echo ${SCD_COLLECT[INCR_COLLECT]}${DES_COLLECT[INCR_COLLECT]} >> ${CRONTAB}
				
				INCR_COLLECT=`/usr/bin/expr ${INCR_COLLECT} + 1`
				
			done	
			
			#'_'문자열을 공백으로 치환.
			${SED} -e 's/@//g' ${CRONTAB} > ${CRONTMP}
			
			${MV} ${CRONTMP} ${CRONTAB}
			
			${SERVICE} crond restart		

		;;		
		
		#수집서버.
		"total")
		
			echo -e [${TIME}]" Choose "${PARAMETER} #>> ${LOGFILE}

			INCR_TOTAL=0
			
			while [ ${INCR_TOTAL} -lt ${SIZE_TOTAL} ]
			do
				
				echo -e [${TIME}]" Copy script : "${ORI_TOTAL[INCR_TOTAL]} #>> ${LOGFILE}

				#스크립트 복사:설치->적용.
				${CP} ${ORI_SCRIPT}/${ORI_TOTAL[INCR_TOTAL]} ${DES_SCRIPT}/${DES_TOTAL[INCR_TOTAL]}
				
				echo ${CMT_TOTAL[INCR_TOTAL]} >> ${CRONTAB}
				
				echo ${SCD_TOTAL[INCR_TOTAL]}${DES_TOTAL[INCR_TOTAL]} >> ${CRONTAB}
				
				INCR_TOTAL=`/usr/bin/expr ${INCR_TOTAL} + 1`
				
			done	
			
			#'_'문자열을 공백으로 치환.
			${SED} -e 's/@//g' ${CRONTAB} > ${CRONTMP}
			
			${MV} ${CRONTMP} ${CRONTAB}
			
			${SERVICE} crond restart		

		;;		
		
		#모니터서버.
		"monitor")
		
			echo -e [${TIME}]" Choose "${PARAMETER} #>> ${LOGFILE}

			INCR_MONITOR=0
			
			while [ ${INCR_MONITOR} -lt ${SIZE_MONITOR} ]
			do
				
				echo -e [${TIME}]" Copy script : "${ORI_MONITOR[INCR_MONITOR]} #>> ${LOGFILE}

				#스크립트 복사:설치->적용.
				${CP} ${ORI_SCRIPT}/${ORI_MONITOR[INCR_MONITOR]} ${DES_SCRIPT}/${DES_MONITOR[INCR_MONITOR]}
				
				echo ${CMT_MONITOR[INCR_MONITOR]} >> ${CRONTAB}
				
				echo ${SCD_MONITOR[INCR_MONITOR]}${DES_MONITOR[INCR_MONITOR]} >> ${CRONTAB}
				
				INCR_MONITOR=`/usr/bin/expr ${INCR_MONITOR} + 1`
				
			done	
			
			#'_'문자열을 공백으로 치환.
			${SED} -e 's/@//g' ${CRONTAB} > ${CRONTMP}
			
			${MV} ${CRONTMP} ${CRONTAB}
			
			${SERVICE} crond restart		

		;;		
		
		#수집/집계 클러스터서버:물리적구성:마스터/슬레이브.
		"p-cluster")	
		
			echo -e [${TIME}]" Choose "${PARAMETER} #>> ${LOGFILE}	

			INCR_PCLUSTER=0
			
			while [ ${INCR_PCLUSTER} -lt ${SIZE_PCLUSTER} ]
			do
				
				echo -e [${TIME}]" Copy script : "${ORI_PCLUSTER[INCR_PCLUSTER]} #>> ${LOGFILE}

				#스크립트 복사:설치->적용.
				${CP} ${ORI_SCRIPT}/${ORI_PCLUSTER[INCR_PCLUSTER]} ${DES_SCRIPT}/${DES_PCLUSTER[INCR_PCLUSTER]}
				
				echo ${CMT_PCLUSTER[INCR_PCLUSTER]} >> ${CRONTAB}
				
				echo ${SCD_PCLUSTER[INCR_PCLUSTER]}${DES_PCLUSTER[INCR_PCLUSTER]} >> ${CRONTAB}
				
				INCR_PCLUSTER=`/usr/bin/expr ${INCR_PCLUSTER} + 1`
				
			done	
			
			#'_'문자열을 공백으로 치환.
			${SED} -e 's/@//g' ${CRONTAB} > ${CRONTMP}
			
			${MV} ${CRONTMP} ${CRONTAB}
			
			${SERVICE} crond restart	
		
		;;
		
		#외부데이터 클러스터서버:논리적구성:마스터/슬레이브.
		"l-cluster")	
		
			echo -e [${TIME}]" Choose "${PARAMETER} #>> ${LOGFILE}	

			INCR_LCLUSTER=0
			
			while [ ${INCR_LCLUSTER} -lt ${SIZE_LCLUSTER} ]
			do
				
				echo -e [${TIME}]" Copy script : "${ORI_LCLUSTER[INCR_LCLUSTER]} #>> ${LOGFILE}

				#스크립트 복사:설치->적용.
				${CP} ${ORI_SCRIPT}/${ORI_LCLUSTER[INCR_LCLUSTER]} ${DES_SCRIPT}/${DES_LCLUSTER[INCR_LCLUSTER]}
				
				echo ${CMT_LCLUSTER[INCR_LCLUSTER]} >> ${CRONTAB}
				
				echo ${SCD_LCLUSTER[INCR_LCLUSTER]}${DES_LCLUSTER[INCR_LCLUSTER]} >> ${CRONTAB}
				
				INCR_LCLUSTER=`/usr/bin/expr ${INCR_LCLUSTER} + 1`
				
			done	
			
			#'_'문자열을 공백으로 치환.
			${SED} -e 's/@//g' ${CRONTAB} > ${CRONTMP}
			
			${MV} ${CRONTMP} ${CRONTAB}
			
			${SERVICE} crond restart	
		;;		
		
		#테스트 클러스터서버:논리적구성:마스터/슬레이브 모두 구성.
		"test-cluster")	
		
			echo -e [${TIME}]" Choose "${PARAMETER} #>> ${LOGFILE}	

			INCR_TESTCLUSTER=0
			
			while [ ${INCR_TESTCLUSTER} -lt ${SIZE_TESTCLUSTER} ]
			do
				
				echo -e [${TIME}]" Copy script : "${ORI_TESTCLUSTER[INCR_TESTCLUSTER]} #>> ${LOGFILE}

				#스크립트 복사:설치->적용.
				${CP} ${ORI_SCRIPT}/${ORI_TESTCLUSTER[INCR_TESTCLUSTER]} ${DES_SCRIPT}/${DES_TESTCLUSTER[INCR_TESTCLUSTER]}
				
				echo ${CMT_TESTCLUSTER[INCR_TESTCLUSTER]} >> ${CRONTAB}
				
				echo ${SCD_TESTCLUSTER[INCR_TESTCLUSTER]}${DES_TESTCLUSTER[INCR_TESTCLUSTER]} >> ${CRONTAB}
				
				INCR_TESTCLUSTER=`/usr/bin/expr ${INCR_TESTCLUSTER} + 1`
				
			done	
			
			#'_'문자열을 공백으로 치환.
			${SED} -e 's/@//g' ${CRONTAB} > ${CRONTMP}
			
			${MV} ${CRONTMP} ${CRONTAB}
			
			${SERVICE} crond restart	
		;;		
		
		*)
			echo -e [${TIME}]" Incorrect Parameter" #>> ${LOGFILE}
		;;			
		
	esac

	echo -e [${TIME}]" End Shell" #>> ${LOGFILE}

}

#함수선언:공통: gcc 설치, sz/rz 설치, yum 설치.
function common(){
	
	echo -e [${TIME}]" Start Common" #>> ${LOGFILE}

	echo -e [${TIME}]" yum install gcc" #>> ${LOGFILE}

	${YUM} install -y gcc gcc-c++

	echo -e [${TIME}]" yum install lrzsz" #>> ${LOGFILE}

	${YUM} install -y lrzsz

	echo -e [${TIME}]" yum clean all" #>> ${LOGFILE}

	${YUM} clean all

	echo -e [${TIME}]" rpm rebuild db" #>> ${LOGFILE}

	${RPM} --rebuilddb

	echo -e [${TIME}]" yum update" #>> ${LOGFILE}

	${YUM} update

	echo -e [${TIME}]" yum epel release" #>> ${LOGFILE}

	${YUM} install -y epel-release

	echo -e [${TIME}]" rpm remi release" #>> ${LOGFILE}

	${RPM} -ivh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
	
	echo -e [${TIME}]" End Common" #>> ${LOGFILE}

}

#함수선언:nodeJS 설치/설정.
function nodejs(){
	
	echo -e [${TIME}]" Start nodeJS" #>> ${LOGFILE}

	cd /root
	
	${WGET} https://nodejs.org/dist/v4.2.4/node-v4.2.4-linux-x64.tar.gz
	
	${TAR} xfz node-v4.2.4-linux-x64.tar.gz
	
	${MV} ./node-v4.2.4-linux-x64 /usr/local/node
	
	#소스 보관.
	#${RM} -rf node-v4.2.4-linux-x64.tar.gz
	
	${RM} -rf node-v4.2.4-linux-x64
	
	echo '# Node.js Exports' >> /etc/profile
	echo 'export NODE_HOME=/usr/local/node' >> /etc/profile
	echo 'export NODE_PATH=$NODE_PATH:/usr/lib/node_modules' >> /etc/profile
	echo 'export PATH=$PATH:$NODE_HOME/bin' >> /etc/profile

	source /etc/profile
	
	${NPM} install xmlrpc
	
	${NPM} install redis
	
	${NPM} install forever -g
	
	${RM} -rf node_modules

	echo -e [${TIME}]" End nodeJS" #>> ${LOGFILE}
	
}

#함수선언:redis 설치.
function redis(){
	
	echo -e [${TIME}]" Start redis" #>> ${LOGFILE}

	cd /root
	
	${WGET} http://download.redis.io/releases/redis-3.0.6.tar.gz
	
	${TAR} xzf redis-3.0.6.tar.gz
	
	cd redis-3.0.6
	
	${MAKE}
	
	cd /
	
	${MKDIR} /srv
	
	${MKDIR} ${REDIS_HOME}
	
	${MKDIR} ${REDIS_HOME}/bin ${REDIS_HOME}/log
	
	cd /root/redis-3.0.6
	
	${CP} *.conf ${REDIS_HOME}
	
	cd src
	
	${CP} -f redis-benchmark redis-check-aof redis-check-dump redis-cli redis-sentinel redis-server redis-trib.rb ${REDIS_HOME}/bin

	cd /srv
	
	${MV} redis redis-3.0.6
	
	${LN} -s redis-3.0.6 redis
	
	#소스 보관.
	#${RM} -rf /root/redis-3.0.6.tar.gz
	
	${RM} -rf /root/redis-3.0.6

	echo -e [${TIME}]" End redis" #>> ${LOGFILE}

}

#함수선언:apache 설치.
function apache(){
	
	#아파치 제거: service httpd stop : yum remove http*
	echo -e [${TIME}]" Start apache" #>> ${LOGFILE}

	${YUM} install -y http*

	echo -e [${TIME}]" End apache" #>> ${LOGFILE}
	
}

#함수선언:php 설치.
function php7(){
	
	echo -e [${TIME}]" Start php" #>> ${LOGFILE}

	${YUM} --enablerepo=remi-php70 install -y php php-cli php-common php-pdo php-mysql php-redis php-xml php-xmlrpc
	
	#php.ini 파일 덮어쓰기.
	${CP} ${ORI_CONFIG}/php.ini /etc/php.ini

	echo -e [${TIME}]" End php" #>> ${LOGFILE}	
	
}

#함수선언:sqlite3 설치.
function sqlite(){
	
	echo -e [${TIME}]" Start sqlite3" #>> ${LOGFILE}

	${YUM} install sqlite3

	echo -e [${TIME}]" End sqlite3" #>> ${LOGFILE}		
	
}

#함수선언:python 설치 및 redis live 설치.
function redis_live(){
	
	echo -e [${TIME}]" Start python" #>> ${LOGFILE}

	${YUM} install python
	
	cd /root
	
	${WGET} https://pypi.python.org/packages/source/d/distribute/distribute-0.7.3.zip
	
	${UNZIP} distribute-0.7.3.zip
	
	cd distribute-0.7.3
	
	${PYTHON} setup.py install
	
	easy_install pip
	
	${PIP} install tornado
	
	${PIP} install redis
	
	${PIP} install python-dateutil
	
	${PIP} install argparse
	
	${CP} ${ORI_SRC}/RedisLive-master.zip /root
	
	cd /root
	
	${UNZIP} RedisLive-master.zip
	
	#/srv/live 폴더가 없으면 생성.
	if [ ! -d /srv/live ]
	then
		${MKDIR} /srv/live
	fi 
	
	${CP} -rf /root/RedisLive-master/* /srv/live
	
	${CP} ${ORI_CONFIG}/redis-live.conf /srv/live/src
	
	cd /root
	
	${RM} -rf distribute-0.7.3

	${RM} -rf RedisLive-master
	
	#${RM} -rf distribute-0.7.3.zip
	
	#${RM} -rf RedisLive-master.zip	

	echo -e [${TIME}]" End python" #>> ${LOGFILE}		
	
}

#함수선언:redis logic sentinel 설정.
function redis_logic_sentinel_config(){
	
	echo -e [${TIME}]" Start redis logic sentinel" #>> ${LOGFILE}

	${MKDIR} ${REDIS_HOME}/5000 ${REDIS_HOME}/6000 ${REDIS_HOME}/7000 
	
	${CP} ${ORI_CONFIG}/monitor_sentinel.conf ${REDIS_HOME}/7000/sentinel.conf
	${CP} ${ORI_CONFIG}/monitor_slave_redis.conf ${REDIS_HOME}/6000/redis.conf
	${CP} ${ORI_CONFIG}/monitor_master_redis.conf ${REDIS_HOME}/5000/redis.conf	

	echo -e [${TIME}]" End redis logic sentinel" #>> ${LOGFILE}		
	
}

#함수선언:redis live 설정.
function redis_live_config(){
	
	echo -e [${TIME}]" Start redis live" #>> ${LOGFILE}

	${CP} ${ORI_CONFIG}/redislive /etc/rc.d/init.d/
	
	${CHMOD} u+x /etc/rc.d/init.d/redislive

	echo -e [${TIME}]" End redis live" #>> ${LOGFILE}		
	
}

#함수선언:ruby & gem 설치.
function rubyngem(){
	
	echo -e [${TIME}]" Start ruby & gem" #>> ${LOGFILE}

	${YUM} install ruby
	
	${YUM} install ruby-rdoc ruby-devel
	
	${YUM} install rubygems
	
	${GEM} install redis

	echo -e [${TIME}]" End ruby & gem" #>> ${LOGFILE}			
	
}

#함수선언:수집/집계 클러스터서버:물리적구성:마스터/슬레이브
function physical_cluster(){
	
	echo -e [${TIME}]" Start collect or total cluster" #>> ${LOGFILE}

	#폴더가 없으면 생성.
	if [ ! -d ${REDIS_HOME}/5000 ]
	then
		${MKDIR} ${REDIS_HOME}/5000
	fi
	
	${CP} ${ORI_CONFIG}/physical_cluster_redis.conf ${REDIS_HOME}/5000/redis.conf	
	
	#맨 마지막 라인에 가상아이피 바인드.
	echo "bind "${INET} >> ${REDIS_HOME}/5000/redis.conf

	echo -e [${TIME}]" End collect or total cluster" #>> ${LOGFILE}		
	
}

#함수선언:외부데이터 클러스터서버:마스터/슬레이브
function logic_cluster(){
	
	echo -e [${TIME}]" Start external cluster" #>> ${LOGFILE}

	#폴더가 없으면 생성.
	if [ ! -d ${REDIS_HOME}/5000 ]
	then
		${MKDIR} ${REDIS_HOME}/5000
	fi
	
	#폴더가 없으면 생성.
	if [ ! -d ${REDIS_HOME}/6000 ]
	then
		${MKDIR} ${REDIS_HOME}/6000
	fi
	
	#폴더가 없으면 생성.
	if [ ! -d ${REDIS_HOME}/7000 ]
	then
		${MKDIR} ${REDIS_HOME}/7000
	fi			
	
	${CP} ${ORI_CONFIG}/logical_5000_cluster_redis.conf ${REDIS_HOME}/5000/redis.conf	
	${CP} ${ORI_CONFIG}/logical_6000_cluster_redis.conf ${REDIS_HOME}/6000/redis.conf	
	${CP} ${ORI_CONFIG}/logical_7000_cluster_redis.conf ${REDIS_HOME}/7000/redis.conf		
	
	#맨 마지막 라인에 가상아이피 바인드.
	echo "bind "${INET} >> ${REDIS_HOME}/5000/redis.conf
	echo "bind "${INET} >> ${REDIS_HOME}/6000/redis.conf	
	echo "bind "${INET} >> ${REDIS_HOME}/7000/redis.conf											

	echo -e [${TIME}]" End external cluster" #>> ${LOGFILE}	
	
}

#함수선언:테스트 클러스터서버:마스터/슬레이브 모두 구성.
function test_cluster(){
	
	echo -e [${TIME}]" Start test cluster" #>> ${LOGFILE}

	#마스터 클러스터.
	#폴더가 없으면 생성.
	if [ ! -d ${REDIS_HOME}/5000 ]
	then
		${MKDIR} ${REDIS_HOME}/5000
	fi
	
	#폴더가 없으면 생성.
	if [ ! -d ${REDIS_HOME}/6000 ]
	then
		${MKDIR} ${REDIS_HOME}/6000
	fi
	
	#폴더가 없으면 생성.
	if [ ! -d ${REDIS_HOME}/7000 ]
	then
		${MKDIR} ${REDIS_HOME}/7000
	fi		
	
	#슬레이브 클러스터.
	#폴더가 없으면 생성.
	if [ ! -d ${REDIS_HOME}/5010 ]
	then
		${MKDIR} ${REDIS_HOME}/5010
	fi
	
	#폴더가 없으면 생성.
	if [ ! -d ${REDIS_HOME}/6010 ]
	then
		${MKDIR} ${REDIS_HOME}/6010
	fi
	
	#폴더가 없으면 생성.
	if [ ! -d ${REDIS_HOME}/7010 ]
	then
		${MKDIR} ${REDIS_HOME}/7010
	fi				
	
	#마스터 클러스터.
	${CP} ${ORI_CONFIG}/test_5000_cluster_redis.conf ${REDIS_HOME}/5000/redis.conf	
	${CP} ${ORI_CONFIG}/test_6000_cluster_redis.conf ${REDIS_HOME}/6000/redis.conf	
	${CP} ${ORI_CONFIG}/test_7000_cluster_redis.conf ${REDIS_HOME}/7000/redis.conf	
	
	#슬레이브 클러스터.
	${CP} ${ORI_CONFIG}/test_5010_cluster_redis.conf ${REDIS_HOME}/5010/redis.conf	
	${CP} ${ORI_CONFIG}/test_6010_cluster_redis.conf ${REDIS_HOME}/6010/redis.conf	
	${CP} ${ORI_CONFIG}/test_7010_cluster_redis.conf ${REDIS_HOME}/7010/redis.conf				
	
	#맨 마지막 라인에 가상아이피 바인드.
	echo "bind "${INET} >> ${REDIS_HOME}/5000/redis.conf
	echo "bind "${INET} >> ${REDIS_HOME}/6000/redis.conf	
	echo "bind "${INET} >> ${REDIS_HOME}/7000/redis.conf	
	
	echo "bind "${INET} >> ${REDIS_HOME}/5010/redis.conf
	echo "bind "${INET} >> ${REDIS_HOME}/6010/redis.conf	
	echo "bind "${INET} >> ${REDIS_HOME}/7010/redis.conf																						

	echo -e [${TIME}]" End test cluster" #>> ${LOGFILE}		
}

if [ $# -lt 1 ]; then
	echo -e " "
	echo -e " usage: ./install.sh <server> "
	echo -e " e.g: ./install.sh collect"
	echo -e " "
	echo -e " collect -> 수집서버"
	echo -e " total -> 집계서버"
	echo -e " monitor -> 모니터 서버"
	echo -e " e-cluster -> 외부 데이터 수집 서버"
	echo -e " c-cluster -> 수집 마스터/슬레이브 클러스터"
	echo -e " t-cluster -> 집계 마스터/슬레이브 클러스터"
	echo -e " test-cluster -> 집계 마스터/슬레이브 클러스터"	
	echo -e " "
	exit 1;
else
	echo -e [${TIME}]" Install Start for "${CHOOSE}" Server V1.0.0.0\n" #>> ${LOGFILE}

	#/root/script 폴더가 없으면 생성.
	if [ ! -d /root/script ]
	then
		${MKDIR} /root/script
	fi

	case ${CHOOSE} in
		#수집서버.
		"collect")
			echo -e [${TIME}]" Choose :"${CHOOSE} #>> ${LOGFILE}

			#함수호출:공통 gcc 설치, sz/rz 설치, yum 설치.
			####common
			
			#함수선언:nodeJS 설치/설정.
			####nodejs
			
			#함수선언:redis 설치.
			####redis

			#함수호출:쉘스크립트
			RESULT=$(shell collect)
			
			echo -e "${RESULT}"  #>> ${LOGFILE}
		;;	
		
		#집계서버.
		"total")
			echo -e [${TIME}]" Choose :"${CHOOSE} #>> ${LOGFILE}

			#함수호출:공통 gcc 설치, sz/rz 설치, yum 설치.
			####common

			#함수선언:apache 설치.
			#####apache

			#함수선언:php 설치.
			####php7

			#함수선언:redis 설치.
			####redis

			#함수호출:쉘스크립트
			RESULT=$(shell total)
			
			echo -e "${RESULT}"  #>> ${LOGFILE}

		;;	
		
		#모니터서버.
		"monitor")
			echo -e [${TIME}]" Choose :"${CHOOSE} #>> ${LOGFILE}

			#함수호출:공통 gcc 설치, sz/rz 설치, yum 설치.
			####common

			#함수선언:redis 설치.
			####redis

			#함수선언:sqlite3 설치.
			####sqlite
			
			#함수선언:python 설치 및 redislive 설치.
			####redis_live
			
			#함수선언:redis logic sentinel 설정.
			####redis_logic_sentinel_config
			
			#함수선언:redis live 설정.
			####redis_live_config

			#함수호출:쉘스크립트
			RESULT=$(shell monitor)
			
			echo -e "${RESULT}"  #>> ${LOGFILE}

		;;		
		
		#수집클러스터서버:물리적구성:마스터/슬레이브.
		"c-cluster")
			echo -e [${TIME}]" Choose :"${CHOOSE} #>> ${LOGFILE}

			#함수호출:공통 gcc 설치, sz/rz 설치, yum 설치.
			####common

			#함수선언:redis 설치.
			####redis

			#함수선언:ruby & gem 설치.
			####rubyngem

			#함수선언:수집/집계 클러스터서버:마스터/슬레이브
			####physical_cluster

			#함수호출:쉘스크립트
			RESULT=$(shell p-cluster)

		;;	
		
		#집계클러스터서버:물리적구성:마스터/슬레이브.
		"t-cluster")
			echo -e [${TIME}]" Choose :"${CHOOSE} #>> ${LOGFILE}

			#함수호출:공통 gcc 설치, sz/rz 설치, yum 설치.
			####common

			#함수선언:redis 설치.
			####redis

			#함수선언:ruby & gem 설치.
			####rubyngem

			#함수선언:수집/집계 클러스터서버:마스터/슬레이브
			####physical_cluster

			#함수호출:쉘스크립트
			RESULT=$(shell p-cluster)

		;;	
		
		#외부데이터 또는 공공데이터 클러스터서버:논리적구성:마스터/슬레이브.
		"e-cluster")
		
			echo -e [${TIME}]" Choose :"${CHOOSE} #>> ${LOGFILE}	
		
			#함수호출:공통 gcc 설치, sz/rz 설치, yum 설치.
			####common

			#함수선언:redis 설치.
			####redis

			#함수선언:ruby & gem 설치.
			####rubyngem

			#함수선언:외부데이터 클러스터서버:마스터/슬레이브
			logic_cluster

			#함수호출:쉘스크립트
			RESULT=$(shell l-cluster)		
		
		;;		
		
		#테스트 클러스터서버:논리적구성:마스터/슬레이브 모두 구성.
		"test-cluster")
		
			echo -e [${TIME}]" Choose :"${CHOOSE} #>> ${LOGFILE}	
		
			#함수호출:공통 gcc 설치, sz/rz 설치, yum 설치.
			####common

			#함수선언:redis 설치.
			####redis

			#함수선언:ruby & gem 설치.
			####rubyngem

			#함수선언:테스트 클러스터서버:마스터/슬레이브 모두 구성.
			test_cluster

			#함수호출:쉘스크립트:테스트 클러스터.
			RESULT=$(shell test-cluster)		
		
		;;																																									
		
		*)
			echo -e [${TIME}]" Incorrect Command" #>> ${LOGFILE}
		;;			
		
	esac	

fi
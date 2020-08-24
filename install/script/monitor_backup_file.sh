#!/bin/bash

DATE=`date +"%Y%m%d"`
TIME=`date +"%Y-%m-%d_%H:%M:%S"`

LOGFILES='/backup/log/backup_files.log'

#백업 폴더가 없으면 생성.
if [ ! -d /backup ]
then
/bin/mkdir /backup
fi

#로그 폴더가 없으면 생성.
if [ ! -d /backup/log ]
then
/bin/mkdir /backup/log
fi

echo -e "\n"[${TIME}]" Backup Files\n " >> ${LOGFILES}

#날짜폴더가 없으면 생성.
if [ ! -d /backup/${DATE} ]
then
/bin/mkdir /backup/${DATE}
echo -e [${TIME}]">>> Create "${DATE}" Directory" >> ${LOGFILES}
fi

###############################################################

#root 폴더가 없으면 생성.
if [ ! -d /backup/${DATE}/root ]
then
/bin/mkdir /backup/${DATE}/root
echo -e [${TIME}]">>> Create root Directory" >> ${LOGFILES}
fi

#root 폴더의 있는 모든 파일을 복사한다.
/bin/cp -rf /root/* /backup/${DATE}/root/

echo -e [${TIME}]">>> Copy root " >> ${LOGFILES}

#백업 경로로 이동한다.
cd /backup/${DATE}/

echo -e [${TIME}]">>> Move "${DATE}" Directory" >> ${LOGFILES}

#복사한 root 폴더를 압축한다.
/bin/tar zcvf ${DATE}_root.tar.gz ./root

echo -e [${TIME}]">>> Compress "${DATE}"_root" >> ${LOGFILES}

#root 폴더를 삭제한다.
/bin/rm -rf /backup/${DATE}/root

echo -e [${TIME}]">>> Delete root Directory" >> ${LOGFILES}

###########################################################

#srv폴더가 없으면 생성.
if [ ! -d /backup/${DATE}/srv ]
then
/bin/mkdir /backup/${DATE}/srv
echo -e [${TIME}]">>> Create srv Directory" >> ${LOGFILES}
fi

#srv 폴더의 있는 모든 파일을 복사한다.
/bin/cp -rf /srv/* /backup/${DATE}/srv/

echo -e [${TIME}]">>> Copy srv " >> ${LOGFILES}

#백업 경로로 이동한다.
cd /backup/${DATE}/

echo -e [${TIME}]">>> Move "${DATE}" Directory" >> ${LOGFILES}

#복사한 srv 폴더를 압축한다.
#명령어 조합.
CMD="/bin/tar zcvf ${DATE}_srv.tar.gz "
CMD=${CMD}"--exclude=./srv/redis-3.0.6/5000/*.aof  " 
CMD=${CMD}"--exclude=./srv/redis-3.0.6/5000/*.rdb "
CMD=${CMD}"--exclude=./srv/redis-3.0.6/5010/*.aof "
CMD=${CMD}"--exclude=./srv/redis-3.0.6/5010/*.rdb "
CMD=${CMD}"--exclude=./srv/redis-3.0.6/6000/*.aof  " 
CMD=${CMD}"--exclude=./srv/redis-3.0.6/6000/*.rdb "
CMD=${CMD}"--exclude=./srv/redis-3.0.6/6010/*.aof "
CMD=${CMD}"--exclude=./srv/redis-3.0.6/6010/*.rdb "
CMD=${CMD}"--exclude=./srv/redis-3.0.6/7000/*.aof  " 
CMD=${CMD}"--exclude=./srv/redis-3.0.6/7000/*.rdb "
CMD=${CMD}"--exclude=./srv/redis-3.0.6/7010/*.aof "
CMD=${CMD}"--exclude=./srv/redis-3.0.6/7010/*.rdb "
CMD=${CMD}"--exclude=./srv/redis-3.0.6/8000/*.aof  " 
CMD=${CMD}"--exclude=./srv/redis-3.0.6/8000/*.rdb "
CMD=${CMD}"--exclude=./srv/redis-3.0.6/8010/*.aof "
CMD=${CMD}"--exclude=./srv/redis-3.0.6/8010/*.rdb "

CMD=${CMD}"./srv"

#조합된 명령어 실행.
${CMD}

echo -e [${TIME}]">>> Compress "${DATE}"_srv" >> ${LOGFILES}

#srv 폴더를 삭제한다.
/bin/rm -rf /backup/${DATE}/srv

echo -e [${TIME}]">>> Delete srv Directory" >> ${LOGFILES}






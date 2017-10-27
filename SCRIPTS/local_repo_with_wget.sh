###########################################################################
##                                                                       ##
##                 CentOS Mirror Script with WGET                        ##
##                                                                       ##
## Creation:    25.02.2014                                               ##
##                                                                       ##
## Copyright(c)2010-2014 by Sergey Budaragin <budaragin_sv@mmbank.ru>    ##
##                                                                       ##
###########################################################################

#!/bin/sh

# Log file
LOGFILE=/var/log/local-repos/remi_repos.log

# Debug file (if you do not want to debug the download process set this option to "/dev/null")
DEBUGFILE=/var/log/local-repos/remi_repos.debug

# test for runing scripts.
echo `date +%d.%m.%Y%t%H:%M:%S` " LOG: Starting local wget synchronization script" >>${LOGFILE}

function log()
  {
    echo `date +%d.%m.%Y%t%H:%M:%S` "    LOG:" $1 >>${LOGFILE}
  }

# Src and sort files of package list from http mirrors
file_html=index.html
file_rpms=files.log

#########################################################################################
#           Creating local mirror of remi repos for rhel6 x86_64                        #
#########################################################################################

cd /srv/repos/remi/6/x86_64/

REMI_SERVER=http://mirror.awanti.com/remi/enterprise/6/remi/x86_64/
REMI_MIRROR=/srv/repos/remi/6/x86_64/

rm -f $file_html
rm -f $file_rpms

log "Receiving the package list from ${REMI_SERVER} ..."
echo "Receiving the package list from ${REMI_SERVER} ..." >> ${DEBUGFILE}

wget -q -O index.html --no-cache ${REMI_SERVER} >> ${DEBUGFILE} 2>&1

log "We receive the list of rpm. Now we compare if the rpm exist in local repos, details in ${DEBUGFILE} file."

grep -Po '<a href=\".*?\.rpm\">' $file_html | cut -d"\"" -f2 > $file_rpms

a=`cat $file_rpms`

for cur_rpm in $a
do
    cur_rpm_file=${REMI_MIRROR}$cur_rpm
    if [ -e $cur_rpm_file ]
    then
         echo "$cur_rpm exist." >> ${DEBUGFILE}
    else
        log "Downloading the  $cur_rpm ..."
        wget --no-cache ${REMI_SERVER}$cur_rpm
        log "ok."
    fi
done

rm -f $file_html
rm -f $file_rpms

log "creating REMI for rhel6 x86_64 mirror repodata"
createrepo --simple-md-filenames --update ${REMI_MIRROR} >> ${LOGFILE}
echo "REMI rhel6 x86_64 local repos is ready."

#########################################################################################
#        Creating local mirror of remi php56 repos for rhel6 x86_64                     #
#########################################################################################

cd /srv/repos/remi/6/php56/x86_64/

REMI_56_SERVER=http://mirror.awanti.com/remi/enterprise/6/php56/x86_64/
REMI_56_MIRROR=/srv/repos/remi/6/php56/x86_64/

rm -f $file_html
rm -f $file_rpms

log "Receiving the package list from ${REMI_56_SERVER} ..."
echo "Receiving the package list from ${REMI_56_SERVER} ..." >> ${DEBUGFILE}

wget -q -O index.html --no-cache ${REMI_56_SERVER} >> ${DEBUGFILE} 2>&1

log "We receive the list of rpm. Now we compare if the rpm exist in local repos, details in ${DEBUGFILE} file."

grep -Po '<a href=\".*?\.rpm\">' $file_html | cut -d"\"" -f2 > $file_rpms

a=`cat $file_rpms`

for cur_rpm in $a
do
    cur_rpm_file=${REMI_56_MIRROR}$cur_rpm
    if [ -e $cur_rpm_file ]
    then
         echo "$cur_rpm exist." >> ${DEBUGFILE}
    else
        log "Downloading the  $cur_rpm ..."
        wget --no-cache ${REMI_56_SERVER}$cur_rpm
        log "ok."
    fi
done

rm -f $file_html
rm -f $file_rpms

log "creating REMI PHP56 for rhel6 x86_64 mirror repodata"
createrepo --simple-md-filenames --update ${REMI_56_MIRROR} >> ${LOGFILE}
echo "REMI PHP56 rhel6 x86_64 local repos is ready."

exit 0

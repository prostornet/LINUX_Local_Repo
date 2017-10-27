###########################################################################
##                                                                       ##
##                 CentOS Mirror Script with RSYNC                       ##
##                                                                       ##
## Creation:    25.02.2014                                               ##
##                                                                       ##
## Copyright(c)2010-2014 by Sergey Budaragin <budaragin_sv@mmbank.ru>    ##
##                                                                       ##
###########################################################################

#!/bin/bash


YA_MIRROR=mirror.yandex.ru
CORB_MIRROR=mirror.vilkam.ru

#CentOS base mirror for 7.0
BASE_SERVER7=${YA_MIRROR}::centos/7/
#BASE_SERVER7=${CORB_MIRROR}::centos/7/
BASE_MIRROR7=/srv/repos/centos/7

#CentOS base mirror for 6.8
BASE_SERVER=${YA_MIRROR}::centos/6.9/
#BASE_SERVER=${YA_MIRROR}::centos/6.7/
#BASE_SERVER=${CORB_MIRROR}::centos/6.7/
BASE_MIRROR=/srv/repos/centos/6.6


#CentOS epel mirror for 6
EPEL6_SERVER=${YA_MIRROR}::fedora-epel/6/
EPEL6_MIRROR=/srv/repos/epel/6

#CentOS epel mirror for 7
EPEL7_SERVER=${YA_MIRROR}::fedora-epel/7/
EPEL7_MIRROR=/srv/repos/epel/7

# Log file
LOGFILE=/var/log/local-repos/centos_repos.log

# Debug file (if you do not want to debug the download process set this option to "/dev/null")
DEBUGFILE=/var/log/local-repos/centos_repos.debug

# Who will be informed in case if anything goes wrong (if you do not want to be informed via mail, set this option to "")
MAILNOTIFY="root@localhost"

# Lock file
LOCK=/var/tmp/centos_mirror.lock

# test for runing scripts.
echo `date +%d.%m.%Y%t%H:%M:%S` " LOG: Starting local rsync script" >>${LOGFILE}

##################################################################
# NORMALY THERE IS NO NEED TO CHANGE ANYTHING BELOW THIS COMMENT #
##################################################################

function log()
  {
    echo `date +%d.%m.%Y%t%H:%M:%S` "    LOG:" $1 >>${LOGFILE}
  }
    
function error()
  { 
    echo `date +%d.%m.%Y%t%H:%M:%S` "    ERROR:" $1 >>${LOGFILE}
    if [ -n "$MAILNOTIFY" ] ; then
      echo `date +%d.%m.%Y%t%H:%M:%S` "    ERROR:" $1 | mail -s "ERROR while synchronizing openSUSE" $MAILNOTIFY
    fi
    echo $1 | grep "Lockfile" >/dev/null
    if [ $? = 1 ] ; then
      rm -f ${LOCK}
    fi
    exit 1
  }
    
function status()
  { 
    case "$1" in
      0)
        log "Synchronization completed."
        ;;
      1)
        error "RSYNC: Syntax or usage error"
        ;;
      2)
        error "RSYNC: Protocol incompatibility"
        ;;
      3)
        error "RSYNC: Errors selecting input/output files, dirs"
        ;;
      4)
        error "RSYNC: Requested action not supported: an attempt was made to manipulate 64-bit files on a platform that cannot support them; or an option was specified that is supported by the client and not by the server."
        ;;
      5)
        error "RSYNC: Error starting client-server protocol"
        ;;
      6)
        error "RSYNC: Daemon unable to append to log-file"
        ;;
      10)
        error "RSYNC: Error in socket I/O"
        ;;
      11)
        error "RSYNC: Error in file I/O"
        ;;
      12)
        error "RSYNC: Error in rsync protocol data stream"
        ;;
      13)
        error "RSYNC: Errors with program diagnostics"
        ;;
      14)
        error "RSYNC: Error in IPC code"
        ;;
      20)
        error "RSYNC: Received SIGUSR1 or SIGINT"
        ;;
      21)
        error "RSYNC: Some error returned by waitpid()"
        ;;
      22)
        error "RSYNC: Error allocating core memory buffers"
        ;;
      23)
        error "RSYNC: Partial transfer due to error"
        ;;
      24)
        error "RSYNC: Partial transfer due to vanished source files"
        ;;
      25)
        error "RSYNC: The --max-delete limit stopped deletions"
        ;;
      30)
        error "RSYNC: Timeout in data send/receive"
        ;;
      *)
        error "RSYNC: Unknown error $1"
        ;;
    esac
  }
    
if [ -f ${LOCK} ] ; then
  error "Lockfile ${LOCK} exists."
fi
  
touch ${LOCK}
 
if [ ! -d ${BASE_MIRROR7} ] ; then
  log "Creating local CentOS7 Base mirror directory."
  mkdir -p ${BASE_MIRROR7}
fi
if [ ! -d ${BASE_MIRROR} ] ; then
  log "Creating local CentOS 6.6 Base mirror directory."
  mkdir -p ${BASE_MIRROR}
fi
if [ ! -d ${EPEL6_MIRROR} ] ; then
  log "Creating local CentOS EPEL 6 mirror directory."
  mkdir -p ${EPEL6_MIRROR}
fi
if [ ! -d ${EPEL7_MIRROR} ] ; then
  log "Creating local CentOS EPEL 7 mirror directory."
  mkdir -p ${EPEL7_MIRROR}
fi

log "Starting CentOS7 Base download process."
rsync -av --delete --partial --exclude "isos/"  --exclude "updates/x86_64/repodata/" --exclude "updates/x86_64/drpms/" --exclude "os/x86_64/repodata/"  --exclude "os/x86_64/RPM-GPG-KEY*" --exclude "fasttrack/" --exclude "extras/x86_64/repodata/" --exclude "extras/x86_64/drpms/" --exclude "centosplus/x86_64/repodata/" --exclude "centosplus/x86_64/drpms/" --delay-updates ${BASE_SERVER7} ${BASE_MIRROR7} >>${DEBUGFILE} 2>&1
status $?

log "Starting CentOS Base download process."
rsync -av --delete --partial --exclude "isos/" --exclude "xen4/" --exclude "updates/x86_64/repodata/" --exclude "updates/x86_64/drpms/" --exclude "updates/i386/drpms/" --exclude "updates/i386/repodata/" --exclude "os/x86_64/repodata/"  --exclude "os/x86_64/RPM-GPG-KEY*" --exclude "os/i386/repodata/" --exclude "os/i386/RPM-GPG-KEY*" --exclude "fasttrack/" --exclude "cr/" --exclude "contrib/" --exclude "extras/x86_64/repodata/" --exclude "extras/x86_64/drpms/" --exclude "extras/i386/drpms/" --exclude "extras/i386/repodata/" --exclude "centosplus/x86_64/repodata/" --exclude "centosplus/x86_64/drpms/" --exclude "centosplus/i386/drpms/" --exclude "centosplus/i386/repodata/" --exclude "SCL/" --delay-updates ${BASE_SERVER} ${BASE_MIRROR} >>${DEBUGFILE} 2>&1
status $?

log "Starting CentOS EPEL6 download process."
rsync -av --delete --partial --exclude "SRPMS/" --exclude "ppc64/"  --exclude "x86_64/repodata/" --exclude "x86_64/debug/" --exclude "i386/repodata/" --exclude "i386/debug/" --delay-updates ${EPEL6_SERVER} ${EPEL6_MIRROR} >>${DEBUGFILE} 2>&1
status $?

log "Starting CentOS EPEL7 download process."
rsync -av --delete --partial --exclude "SRPMS/" --exclude "ppc64/" --exclude "ppc64le/" --exclude "aarch64/" --exclude "x86_64/repodata/" --exclude "x86_64/debug/" --delay-updates ${EPEL7_SERVER} ${EPEL7_MIRROR} >>${DEBUGFILE} 2>&1
status $?

rm -f ${LOCK}

log "creating BASE updates 7 x86_64 repodata"
createrepo --update ${BASE_MIRROR7}/updates/x86_64/ >> ${LOGFILE}
echo "BASE update 7 x86_64 local repos is ready."

log "creating BASE os 7 x86_64 repodata"
createrepo --update --simple-md-filenames -vg ${BASE_MIRROR7}/os/x86_64/repodata/c7x64-comps.xml ${BASE_MIRROR7}/os/x86_64/ >> ${LOGFILE}
echo "BASE os 7 x86_64 local repos is ready."

log "creating BASE extras 7 x86_64 repodata"
createrepo --update ${BASE_MIRROR7}/extras/x86_64/ >> ${LOGFILE}
echo "BASE extras 7 x86_64 local repos is ready."

log "creating BASE centosplus 7 x86_64 repodata"
createrepo --update ${BASE_MIRROR7}/centosplus/x86_64/ >> ${LOGFILE}
echo "BASE centosplus 7 x86_64 local repos is ready."

log "creating BASE updates x86_64 repodata"
createrepo --update ${BASE_MIRROR}/updates/x86_64/ >> ${LOGFILE}
echo "BASE update x86_64 local repos is ready."

log "creating BASE updates i386 repodata"
createrepo --update ${BASE_MIRROR}/updates/i386/ >> ${LOGFILE}
echo "BASE update i386 local repos is ready."

log "creating BASE os x86_64 repodata"
createrepo --update --simple-md-filenames -vg ${BASE_MIRROR}/os/x86_64/repodata/c6x64-comps.xml ${BASE_MIRROR}/os/x86_64/ >> ${LOGFILE}
echo "BASE os x86_64 local repos is ready."

log "creating BASE os i386 repodata"
createrepo --update --simple-md-filenames -vg ${BASE_MIRROR}/os/i386/repodata/c6i386-comps.xml ${BASE_MIRROR}/os/i386/ >> ${LOGFILE}
echo "BASE os i386 local repos is ready."

log "creating BASE extras x86_64 repodata"
createrepo --update ${BASE_MIRROR}/extras/x86_64/ >> ${LOGFILE}
echo "BASE extras x86_64 local repos is ready."

log "creating BASE extras i386 repodata"
createrepo --update ${BASE_MIRROR}/extras/i386/ >> ${LOGFILE}
echo "BASE extras i386 local repos is ready."

log "creating BASE centosplus x86_64 repodata"
createrepo --update ${BASE_MIRROR}/centosplus/x86_64/ >> ${LOGFILE}
echo "BASE centosplus x86_64 local repos is ready."

log "creating BASE centosplus i386 repodata"
createrepo --update ${BASE_MIRROR}/centosplus/i386/ >> ${LOGFILE}
echo "BASE centosplus i386 local repos is ready."

log "creating EPEL6 x86_64 mirror repodata"
createrepo --update --simple-md-filenames -vg ${EPEL6_MIRROR}/x86_64/repodata/x86_64-comps-el6.xml ${EPEL6_MIRROR}/x86_64/ >> ${LOGFILE}
echo "EPEL rhel6 x86_64 local repos is ready."

log "creating EPEL6 i386 mirror repodata"
createrepo --update --simple-md-filenames -vg ${EPEL6_MIRROR}/i386/repodata/i386-comps-el6.xml ${EPEL6_MIRROR}/i386/
echo "EPEL rhel6 i386 local repos is ready."

log "creating EPEL7 x86_64 mirror repodata"
createrepo --update --simple-md-filenames -vg ${EPEL7_MIRROR}/x86_64/repodata/x86_64-comps-el7.xml ${EPEL7_MIRROR}/x86_64/
echo "EPEL7 x86_64 local repos is ready."

exit 0

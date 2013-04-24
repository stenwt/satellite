#!/bin/bash - 
#===============================================================================
#
#          FILE:  custom-backup.sh
# 
#         USAGE:  ./custom-backup.sh 
# 
#   DESCRIPTION: Implements simple backup + restore over SSH with key exchange to DR server
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES: 
#        AUTHOR: Sten Turpin (sten@redhat.com), Red Hat Consulting
#       COMPANY: 
#       CREATED: 04/22/2013 04:28:12 PM CDT
#      REVISION:  --- 
#===============================================================================

set -o nounset                              # Treat unset variables as an error


BACKUPDIR=/var/satellite/.backup/backup-$(date --iso)
TARGET=SOMEHOSTNAME

RSYNC="/etc/pki/spacewalk/ /etc/sysconfig/rhn/ /etc/rhn/ /etc/tnsnames.ora /etc/xinetd.d/tftp /var/www/html/pub/ /var/satellite/ /root/.gnupg/ /root/ssl-build/ /etc/dhcp.conf /etc/httpd/ /var/lib/tftpboot/ /var/lib/cobbler/ /var/lib/rhn/kickstarts/ /etc/cobbler/settings /etc/jabberd/ /var/www/cobbler/ /var/lib/nocpulse/"

function log {
  STAMP=$(date +"%Y-%m-%d %H:%M:%S")
  if [ $1 == "error" ]
  then
    echo "$STAMP - ERROR - $2"
    exit 2;
  elif [ $1 == "info" ]
  then
    echo "$STAMP - info - $2"
  elif [ $1 == "debug" ]
  then
    if [ -n $DEBUG ]
    then
      echo "$STAMP - debug - $2"
    fi
  else
    echo "$STAMP - ERROR: invalid log level passed to log function: $*"
  fi
}

log info "Stopping Satellite server"
/usr/sbin/rhn-satellite stop  || log error "Something went wrong stopping Satellite!"

log info "Creating backupdir $BACKUPDIR"
[ -d $BACKUPDIR ] || mkdir -p $BACKUPDIR
chown oracle:dba $BACKUPDIR

log info "Creating Oracle backup"
su - oracle -c "db-control backup $BACKUPDIR"

log info "Checking Oracle backup"
su - oracle -c "db-control examine $BACKUPDIR"

[ $(date +%a) == "Sat" ] && \
  log info "Deeply verifying Oracle backup because it's Saturday" && \
  su - oracle -c "db-control verify $BACKUPDIR"

log info "rsyncing files to $TARGET"
for X in $RSYNC
do
  rsync -a $X $TARGET:$X
done

log info "Re-starting Satellite."
/usr/sbin/rhn-satellite start

log info "Executing Oracle import on $TARGET"
ssh $TARGET "su - oracle -c \"db-control restore $BACKUPDIR\" "

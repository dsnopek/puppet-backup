#!/bin/bash
 
### Duplicity Setup ###
. /etc/duplicity/defaults.conf
 
S3MYSQLLOCATION="<%= @s3path %>"
S3OPTIONS="--s3-use-new-style --s3-use-rrs"
 
### MySQL Setup ###
MUSER="<%= @mysql_user %>"
MPASS="<%= @mysql_password %>"
MHOST="localhost"
 
### Disable MySQL ###
# Change to 0 to disable
BACKUPMYSQL=1
 
###### End Of Editable Parts ######
 
### Env Vars ###
export PASSPHRASE AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY
 
### Commands ###
if [[ -n "$BACKUPMYSQL" && "$BACKUPMYSQL" -gt 0 ]]; then
 MYSQLTMPDIR="$(mktemp -d)"
 MYSQL="$(which mysql)"
 MYSQLDUMP="$(which mysqldump)"
 GZIP="$(which gzip)"
fi
DUPLICITY="$(which duplicity)"

if [[ -n "$BACKUPMYSQL" && "$BACKUPMYSQL" -gt 0 ]]; then
 if [[ -z "$MYSQL" || -z "$MYSQLDUMP" || -z "$GZIP" ]]; then
  echo "Not all MySQL commands found."
  exit 2
 fi
fi
if [ -z "$DUPLICITY"  ]; then
 echo "Duplicity not found."
 exit 2
fi
 
### Dump MySQL Databases ###
if [[ -n "$BACKUPMYSQL" && "$BACKUPMYSQL" -gt 0 ]]; then
 # Get all databases name
 DBS="$($MYSQL -u $MUSER -h $MHOST -p$MPASS -Bse 'show databases')"
 for db in $DBS
 do
  if [ "$db" != "information_schema" ]; then
   
   $MYSQLDUMP -u $MUSER -h $MHOST -p$MPASS $db | $GZIP -9 > $MYSQLTMPDIR/mysql-$db
  fi
 done
fi
 
### Backup files ###
if [[ -n "$BACKUPMYSQL" && "$BACKUPMYSQL" -gt 0 ]]; then
 if [ -n "$S3MYSQLLOCATION" ]; then
  $DUPLICITY --full-if-older-than $FULLDAYS $S3OPTIONS $EXTRADUPLICITYOPTIONS --allow-source-mismatch $MYSQLTMPDIR $S3MYSQLLOCATION
 fi
fi
 
### Cleanup ###
if [[ -n "$MAXFULL" && "$MAXFULL" -gt 0 ]]; then
 if [[ -n "$BACKUPMYSQL" && "$BACKUPMYSQL" -gt 0 ]]; then
  if [ -n "$S3MYSQLLOCATION" ]; then
   $DUPLICITY remove-all-but-n-full $MAXFULL $S3MYSQLLOCATION
  fi
 fi
fi
if [[ -n "$BACKUPMYSQL" && "$BACKUPMYSQL" -gt 0 ]]; then
 rm -rf $MYSQLTMPDIR
fi


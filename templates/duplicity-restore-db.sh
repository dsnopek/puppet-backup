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

### Restore files ###
if [ -n "$S3MYSQLLOCATION" ]; then
 $DUPLICITY restore $S3OPTIONS $EXTRADUPLICITYOPTIONS -t $1 --file-to-restore mysql-$2 $S3MYSQLLOCATION $MYSQLTEMPDIR/mysql-$2
fi

if [[ -n $3 ]]; then
 mv $MYSQLTEMPDIR/mysql-$2 $3
else
 # TODO: actually restore the database!
fi
  
if [[ -n "$BACKUPMYSQL" && "$BACKUPMYSQL" -gt 0 ]]; then
 rm -rf $MYSQLTMPDIR
fi


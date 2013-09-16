#!/bin/bash
 
### Duplicity Setup ###
. /etc/duplicity/defaults.conf
 
# This needs to be a newline separated list of files and directories to backup
INCLUDEFILES="/etc/duplicity/server-filelist.txt"
 
S3FILESYSLOCATION="<%= @s3path %>"
S3OPTIONS="--s3-use-new-style --s3-use-rrs"
 
###### End Of Editable Parts ######
 
### Env Vars ###
export PASSPHRASE AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY
 
### Commands ###
DUPLICITY="$(which duplicity)"

if [ -z "$DUPLICITY"  ]; then
 echo "Duplicity not found."
 exit 2
fi
 
### Restore files ###
if [ -n "$S3FILESYSLOCATION" ]; then
 $DUPLICITY restore $S3OPTIONS $EXTRADUPLICITYOPTIONS -t $1 --file-to-restore $2 $S3FILESYSLOCATION $3
fi
 

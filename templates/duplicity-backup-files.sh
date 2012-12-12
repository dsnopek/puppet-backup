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
 
### Backup files ###
if [ -n "$S3FILESYSLOCATION" ]; then
 $DUPLICITY --full-if-older-than $FULLDAYS $S3OPTIONS $EXTRADUPLICITYOPTIONS --include-globbing-filelist $INCLUDEFILES --exclude '**' / $S3FILESYSLOCATION
fi
 
### Cleanup ###
if [[ -n "$MAXFULL" && "$MAXFULL" -gt 0 ]]; then
 if [ -n "$S3FILESYSLOCATION" ]; then
  $DUPLICITY remove-all-but-n-full $MAXFULL $S3FILESYSLOCATION
 fi
fi


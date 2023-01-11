#!/bin/bash
#
# Delete old gitlab backups

# Variables
GITLABBACKUPS=/var/opt/gitlab/backups
BACKUPDAYS=15

# Cleanup old backups
find $GiTLABBACKUPS -type f -ctime +$BACKUPDAYS -exec rm -f {} \;

#!/bin/bash
#
# Delete old gitlab backups

# Variables
GITLABBACKUPS=/var/opt/gitlab/backups
BACKUPDAYS=15

# Cleanup old backups
find $GiTLABBACKUPS -type f -ctime +$BACKUPDAYS -exec rm -f {} \;

# or you edit /etc/gitlab/gitlab.rb
# gitlab_rails['backup_keep_time'] = 604800
# After changing conf in gitlab.rb you must run command `gitlab-ctl reconfigure` to apply

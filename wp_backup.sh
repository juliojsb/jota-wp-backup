#!/bin/bash
#
# Author        :Julio Sanz
# Website       :www.elarraydejota.com
# Email         :juliojosesb@gmail.com
# Description   :Backup files and databases of Wordpress sites
#                Execute with root user at system level
# Dependencies  :You need to setup passworldless mysqldump in your config file, preferably with a MySQL backup only account
#                See README of this repo to check how to configure it
# Usage         :./wp_backup.sh
# License       :GPLv3
#


#
# VARIABLES
#

IFS=','
cnf_file="/root/.my.cnf"
sitelist="$(dirname $0)/wpsitelist"
dateformat=$(date +%Y%m%d)
notification_email="email@example.com"
retention=15
backup_dir="/backups/wordpress"
# Backup user (MySQL user, not system one!)
backup_user="backupuser"


#
# FUNCTIONS
#

backup_wp_site(){
    while read wp_site wp_folder wp_database;do
        echo "--- Performing backup of ${wp_site}"
        mkdir -p ${backup_dir}/${wp_site}/${dateformat}
        cd $(dirname $wp_folder)
        tar -zcf files.tar.gz $(basename $wp_folder)
        mysqldump --defaults-extra-file="$cnf_file" -u"$backup_user" -h localhost "$wp_database" > database.sql
        # Move backups to backup folder
        mv database.sql ${backup_dir}/${wp_site}/${dateformat}/
        mv files.tar.gz ${backup_dir}/${wp_site}/${dateformat}/
        # Clear old backups
        find ${backup_dir}/${wp_site} -mindepth 1 -maxdepth 1 -mtime +"$retention" -exec rm -rf "{}" ";" > /dev/null
        echo "  - Done!"
    done<${sitelist}
}

send_notification(){
# To logger
echo "Notification - Wordpress backup performed in $(hostname)" | logger

# To mail
mail -s "Notification - Wordpress backup performed in $(hostname)" "$notification_email" <<- END_MAIL
Wordpress backups successfully completed
-- Current date is $(date)
-- Server $(hostname)
$(ls -1 ${backup_dir} | sed 's/^/   /')
END_MAIL
}

how_to_use(){
    echo "This is not the way this script is meant to be used..."
    echo "This script works without additional arguments, so just execute it -> ./wp_backup.sh"
    exit 1
}

#
# MAIN
#

# Initial syntax check
if [ $# -ne 0 ];then
    how_to_use
else
    backup_wp_site
    send_notification
    exit 0
fi

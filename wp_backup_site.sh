#!/bin/bash
#
# Script        :wp_backup_site.sh
# Author        :Julio Sanz
# Website       :www.elarraydejota.com
# Email         :juliojosesb@gmail.com
# Tested in     :Debian 7/8
# Description   :Script to backup a Wordpress site. It backups both Wordpress files (contents, core files...)
#                and Wordpress database. The idea is to put it in a crontab to automate the process
# Dependencies  :None
# Usage         :./wp_backup_site.sh
# License       :GPLv3
#
########################################################################################################

#==========================
# VARIABLES
#==========================

# Date variable for everyday. It will have the format 20150507 -> year 2015, month 05, day 07
v_date=$(date +%Y%m%d)
# Wordpress database user
wpdb_user="your_wordpress_database_user"
# Wordpress database password
wpdb_pass="your_wordpress_database_pass"
# Wordpress database name
wpdb_dbname="your_wordpress_database_name"
# Email to send a notification when a backup is done
wp_email="youremail@domain.com"
# Wordpress installation location (without final slash!) e.g.:/var/www/sites/mysite.com
wp_documentroot="your_wordpress_documentroot"
# Wordpress backup destination directory e.g.: /usr/local/backups/wordpress (without final slash!)
wp_backup_dir="your_wordpress_backup_destination_directory"
# Retention time for backups (older backups get deleted)
retention_time=15
# Set gzip maximum possible compression
export GZIP=-9

#==========================
# FUNCTIONS
#==========================

backup_wp_site(){
	# Create backup directories
	mkdir -p $wp_backup_dir/$v_date/files
	mkdir -p $wp_backup_dir/$v_date/database
	# Backup core and content files
	cp -R $wp_documentroot/* $wp_backup_dir/$v_date/files/
	# Backup site database
	mysqldump -u"$wpdb_user" -p"$wpdb_pass" -h localhost \
	"$wpdb_dbname" > "$wp_backup_dir"/$v_date/database/"$wpdb_dbname"_backup.sql
	# Create TAR package and compress with GZIP
	cd $wp_backup_dir
	tar -zcvf $v_date.tar.gz $v_date/ --remove-files
}

clear_old_backups(){
	# Delete old backups created mtime days ago specified by retention_time variable
	find $wp_backup_dir -maxdepth 1 -mtime +$retention_time -exec rm -rf "{}" ";" > /dev/null
}

send_notification(){
	# Send mail to confirm that everything has worked as expected
	mail -s "BACKUP - Wordpress backup of files/database successfully completed in $(hostname)" "$wp_email" <<- END_MAIL
	-- Current date is $(date)
	-- Server $(hostname)
	-- Backup performed is $v_date.tar.gz
	-- Backups available in $wp_backup_dir
	$(ls -1 $wp_backup_dir | sed 's/^/   /')
	END_MAIL
}

how_to_use(){
	echo "This is not the way this script is meant to be used..."
	echo "This script works without additional arguments, so just execute it -> ./wp_backup.sh"
	exit 1
}

#==========================
# MAIN
#==========================

# Initial syntax check

# Initial syntax check, script just needs a parameter...
if [ $# -ne 0 ];then
	how_to_use
else
	backup_wp_site
	clear_old_backups
	send_notification
	exit 0
fi

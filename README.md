# jota-wp-backup

## Description

Bash script to perform a backup of files and database of a list of Wordpress sites.

## Requirements

The script uses a MySQL user with limited privileges to perform backups.

1. Create database user to perform backups:

```
GRANT LOCK TABLES, SELECT ON *.* TO 'backupuser'@'localhost' IDENTIFIED BY 'pass1234';
```

2. At system level, create the file **.my.cnf** in the user's home that is going to launch the script. This file is used to launch mysqldump without prompting for password. Set permissions of the file to 640 for better security:

```
[mysqldump]      
user=backupuser
password=pass1234
```

3. Create the backups folder defined in **backup_dir** variable.
4. Adjust other variables as needed.

## Usage

1. Define the list of sites you want to backup in the file **wpsitelist** with the following format:

```
wp_sitename,wp_path,wp_database
```

Where:

* **wp_sitename**: the name of the site (you can put here the domain, subdomain, or whatever name is useful for you)
* **wp_path**: path of the Wordpress installation
* **wp_database**: database name of the Wordpress site

For example:
```
site1,/srv/app1,dbtest1
site2,/srv/app2,dbtest2
```

2. Configure a notification mail in the variable **notification_email**


3. Launch the script from the shell:

```bash
./wp_backup.sh
```

The output should be:

```
--- Performing backup of site1
  - Done!
--- Performing backup of site2
  - Done!
```

Once performed you can find the backups in the folder defined in the variable
``` 
└── wordpress
    ├── site1
    │   └── 20191212
    │       ├── database.sql
    │       └── files.tar.gz
    └── site2
        └── 20191212
            ├── database.sql
            └── files.tar.gz
```

You can adjust the other variables from the script as you need.

#!/bin/bash
# Author Roger Gentry (jamesrascal) - Host Kraken
# WP BACKUPS V1.8
# Build date 07/14/2014

# Adjust this to where you websites are stored.
FINDDIR=/home/

# Searches for the backup.profile in the web directory.
profile=$(find ${FINDDIR} -wholename "*backup.profile" )

for backupprofile in $profile ; do
echo "********************************************************************";
echo "Using Profile: ${backupprofile}";
. $backupprofile
                if [ "${backup_enabled}" = "1" ]; then
                                # BackupName Date and time
                                backupname=${wp_domin}-$(date +%m%d%y)
                                echo "Backing up WordPress site at ${wp_root}";
                                # Pulls Database info from WP-config
                                db_name=$(grep DB_NAME "${wp_root}/wp-config.php" | cut -f4 -d"'")
                                db_user=$(grep DB_USER "${wp_root}/wp-config.php" | cut -f4 -d"'")
                                db_pass=$(grep DB_PASSWORD "${wp_root}/wp-config.php" | cut -f4 -d"'")
                                table_prefix=$(grep table_prefix "${wp_root}/wp-config.php" | cut -f2 -d"'")

                                # Creates a Backup Directory if one does not exist.
                                mkdir -p ${backup_location}/${user}/
                                mkdir -p ${backup_location}/${user}/${wp_domain}/
                                
                                # Make Backup location the current directory
                                cd ${backup_location}/${user}/${wp_domain}


                                # MySQL Takes a Dump and compress the Home Directory
                                mysqldump -u ${db_user} -p${db_pass} ${db_name} > ./${backupname}-DB.sql &&
                                tar zcPf ./${backupname}-FILES.tar.gz ${wp_root}

                                # Compresses the MySQL Dump and the Home Directory
                                tar zcPf ./WPBACKUP-${backupname}.tar.gz ./${backupname}.tar.gz ./${backupname}.sql

                                # Generates the Backup Size
                                FILENAME=${backup_location}/${user}/${wp_domain}/WPBACKUP-${backupname}.tar.gz
                                FILESIZE=$(du -h "$FILENAME")
                                echo "$FILESIZE"

                                #Removes the SQL dump and Home DIR to conserve space
                                rm -rf ./${backupname}.tar.gz ./${backupname}.sql

                                #Deletes any Backup older than X days
                              find ${backup_location}/${user}/${wp_domain}/ -type f -mtime +${keepdays} -exec rm {} \;
                fi
                if [ "${backupenabled}" = "0" ]; then
                                echo "Backups NOT enabled for ${wp_root}";
                fi
done
echo " ";
echo "********************************************************************";
echo "This script is licensed under GPL https://github.com/jamesrascal/wordpress-backup/";
echo "Run Date: $(date +%m%d%y%k%M)";

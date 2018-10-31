#!/bin/bash

# following instructions from https://github.com/awslabs/cfncluster/issues/170
#
# by default, /shared, /home, /opt/sge are shared from master, so we only need to add users
#
# list user and userid in a file
# awk -F: '/\/home/ {printf "%s,%s\n",$1,$3}' /etc/passwd > /home/ec2-user/cfnclusterusers.txt
# chmod -w /home/ec2-user/cfnclusterusers.txt
#
# need linux line ending, copy this file to S3 and make it public readable
# dos2unix cfncluster_adduser.sh
# aws s3 cp --acl public-read cfncluster_adduser.sh s3://xxx/cfncluster_adduser.sh
#

IFS=","
while read USERNAME USERID
     do
     # -M do not create home since Master node is exporting /homes via NFS
     # -u to set UID to match what is set on the Master node
	 if ! [ `id -u $USERNAME 2>/dev/null || echo -1` -ge 0 ]; then 
		useradd -M -u $USERID $USERNAME
	fi	
done < "/home/ec2-user/cfnclusterusers.txt"

exit 0

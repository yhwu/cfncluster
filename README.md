# cfncluster
Create, customize, usage

- First thing first, work with a properly configued VPC. Make sure the instances launched in the VPC can communicate within permissions.
- If error occurs, it's mostly due to comminication. Check security groups, pay attention to both inbound and outbound rules.
- In order to be able to add more users, add a post install script. Check the adduser script.
- Post install script must exit 0, and must end lines with linux line ending.
- Add user on Master, see https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/managing-users.html 

```
cfncluster configure -c ~/.cfncluster/cfncluster.config
cfncluster create --norollback -c ~/.cfncluster/cfncluster.config vpchpc
cfncluster list
cfncluster delete vpchpc
```

#### Change master and compute volumes
- compute node volume can be changed from cloudFormation console by configuration
- master node volume can be changed from EC2 console by the instance 
- after changing the volumes, follow the instructions from https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/recognize-expanded-volume-linux.html

```
df -h
lsblk
# xvda    202:0    0  15G  0 disk
# └─xvda1 202:1    0  15G  0 part /
# xvdb    202:16   0  50G  0 disk /shared

# to extend xvdb file system
sudo resize2fs /dev/xvdb
# to extend xvda1 partition
sudo growpart /dev/xvda 1
reboot
```

#### Add new user
- add newuser in master node  
- modify /home/ec2-user/cfnclusteruser.txt in order for post install script to pick up user information 

```
sudo adduser newuser
sudo su - newuser
cd
mkdir .ssh
ssh-keygen -t rsa
cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys
chmod 700 .ssh
chmod 600 .ssh/authorized_keys
# send ~/.ssh/id_rsa to newuser

# login as ec20-user
awk -F: '/\/home/ {printf "%s,%s\n",$1,$3}' /etc/passwd > /home/ec2-user/cfnclusterusers.txt
```


#### Request number of nodes
```
ASG=cfncluster-vpchpc-ComputeFleet-Jxxx9
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $ASG

# request 4 nodes, note after idling more than evaluation periods, they will be terminated.
aws autoscaling set-desired-capacity --auto-scaling-group-name $ASG --desired-capacity 4
aws autoscaling describe-auto-scaling-instances

# maintain 5 nodes
aws autoscaling update-auto-scaling-group --auto-scaling-group-name $ASG --min-size 5 --max-size 5

# stop and resume Terminate
aws autoscaling suspend-processes --auto-scaling-group-name $ASG --scaling-processes  Terminate
aws autoscaling resume-processes --auto-scaling-group-name $ASG --scaling-processes  Terminate
```

# SGE qsub etc

## qsub file header
#!/bin/bash
#$ -S bash
#$ -N ML
#$ -cwd
#$ -V
#$ -j yes
#$ -pe smp 7       # assuming each node has 8 cores, this option reserves the whole node
#$ -R yes
#$ -r yes
#$ -l h_vmem=15G
#$ -l mem_free=14G
#$ -t 1-2
#$ -tc 10


# hold a job
qalter -h u $jobid
qalter -h U $jobid # unhold


# list all parallel enviroments
qconf -sql

# check properties for all.q
qconf -sq all.q

qsub
qstat
qdel
qhost

## rerun a job in case the host went away
# https://forums.aws.amazon.com/thread.jspa?threadID=178780
# If you modify the SGE configuration with "qconf -mconf" (as root) and set "reschedule_unknown" to a non-zero value, a job submitted as re-runnable (-r y) will automatically be rerun on another host once it becomes available.
# Jobs or tasks without checkpointing would be started from scratch on the new instances once they became available.
#If you'd like, you can test this behavior by running standard on-demand instances, submit a job to them, then terminate the instance. The job should automatically start up again with a "R" state in qstat showing it's been rerun on a new instance.
sudo su sgeadmin
qconf -mconf
qconf -rattr queue rerun TRUE all.q


## clean up hosts that are terminated but still registered in SGE
# https://forums.aws.amazon.com/thread.jspa?threadID=241553
sudo su sgeadmin
qconf -sql
qmod -d all.q
# make sure to delete all registed jobs from all usters for the queue.
qdel -f 307
qconf -de ip-10-0-0-xx
qhost | awk '/ip/{print $1}' | xargs -n 1 qconf -de
# if Host object is still referenced in cluster queue "all.q". Use the following to remove the host. 
# If nothing left in allhosts, use None 
qconf -mq all.q
qconf -mhgrp @allhosts


## resub jobs on runaway nodes, run as user, note qresub before qdel
qhost | awk '/ip/ && $NF=="-"' > gonenodes.txt
gnodes=`awk '{print $1}' gonenodes.txt | xargs | sed 's/ /\\\|/g'`
qstat -u "*" | grep $gnodes > stalejobs.txt
awk '{print $1}' stalejobs.txt | xargs -n 1 qresub
## remove runaway nodes from SGE 
sudo su sgeadmin
awk '{print $1}' stalejobs.txt | xargs -n 1 qdel -f 
awk '{print $1}' gonenodes.txt | xargs -n 1 qconf -de

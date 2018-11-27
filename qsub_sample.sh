#!/bin/bash
#$ -N test
#$ -cwd
#$ -V
#$ -j yes
#$ -pe smp 6
#$ -R yes
##$ -l h_vmem=15G
##$ -l mem_free=14G
#$ -t 1-4
#$ -tc 20

if [ -z "${SGE_TASK_ID}" ]; then
    SGE_TASK_ID=1
fi
i=$(expr $SGE_TASK_ID - 1)
allinputs=($(seq -f '%04G' 0 100))
myinput=${allinputs[$SGE_TASK_ID]}
myhost=$(hostname)
echo $SGE_TASK_ID $SGE_TASK_LAST $myhost $myinput

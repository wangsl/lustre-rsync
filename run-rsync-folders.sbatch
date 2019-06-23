#!/bin/bash

#SBATCH --job-name=rsync
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --tasks-per-node=28
#SBATCH --time=168:00:00
#SBATCH --mem=120GB
#SBATCH --qos=sysadm
#SBATCH --reservation=lustre
##SBATCH --partition=c01_25
#SBATCH --exclusive
#SBATCH --output=slurm-logs/slurm-%j.out

dir="$@"

if [ "$dir" == "" ]; then exit; fi
if [[ ! $dir =~ ^/oldscratch/ ]]; then exit; fi
if [ ! -d "$dir" ]; then exit; fi

dir=$(readlink -e "$dir")

log="$(echo "$dir" | sed -e 's#^/oldscratch/##')"
log="/scratch/wang-14k/lustre-rsync/rsync-logs/$log.log"

cat<<EOF 2>&1 | tee $log
JobID: $SLURM_JOB_ID
Directory: $dir
Host: $(hostname)
JobStarTime: $(date)

EOF

sudo /share/apps/lustre-copy/rsync-folder.sh --folders "$dir" >> $log 2>&1

#/share/apps/lustre-copy/rsync-folder.sh --files $dir
    
cat<<EOF 2>&1 | tee -a $log

JobFinishTime: $(date)

EOF



#!/bin/bash

dir=/scratch/wang
dir=/scratch/work/public
dir=/scratch/cgsb
dir=/scratch/olympus

dir="$@"

cat<<EOF
JobID: $SLURM_JOB_ID
Directory: $dir
Host: $(hostname)
JobStarTime: $(date)
EOF

/share/apps/lustre-copy/rsync-folder.sh --folders "$dir"

#/share/apps/lustre-copy/rsync-folder.sh --files $dir

cat<<EOF
JobFinishTime: $(date)

EOF


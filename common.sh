#!/bin/bash

parallel=/share/apps/parallel/20171022/bin/parallel

rsync_non_recursive=/share/apps/lustre-copy/rsync-non-recursive.sh
psync_based_on_files=/share/apps/lustre-copy/psync-based-on-files.sh
psync_based_on_folders=/share/apps/lustre-copy/psync-based-on-folders.sh

tmp_dir=/state/partition1/rsync-tmp

scratch_tmp_dir=/mnt/scratch/rsync-tmp

partial_dir=/state/partition1/rsync-tmp

logs_dir=/state/partition1/rsync-logs

mkdir -m 1777 -p $tmp_dir $partial_dir $logs_dir

source_prefix=/scratch
target_prefix=/mnt/scratch/data

rsync_alias="/usr/bin/rsync -hAHXcdlptgoDv --numeric-ids --stats --delete --progress --partial-dir=$partial_dir --temp-dir=$scratch_tmp_dir"

n_jobs=50

n_lines=500





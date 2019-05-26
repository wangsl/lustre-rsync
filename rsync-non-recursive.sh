#!/bin/bash

source /share/apps/lustre-copy/common.sh

log_file=$(/usr/bin/mktemp --dry-run $logs_dir/rsync-XXXXXXXXXXXX.log)

if [ $# -ne 2 ]; then
    echo "Usage error: $0: source_folder target_folder"
    exit 1
fi

source_dir="$1"
target_dir="$2"

if [ ! -d "$source_dir" ]; then echo "source $source_dir is not a folder"; exit 1; fi
if [ ! -d "$target_dir" ]; then echo "target $target_dir is not a folder"; exit 1; fi

ok=1
{
    echo
    echo "source_dir: $source_dir"
    echo "target_dir: $target_dir"
    date
    echo
    $rsync_alias "$source_dir/" "$target_dir/" || ok=0
} > $log_file 2>&1

info="[$(date '+%Y-%m-%dT%H:%M:%S.%3N')] $(hostname); $source_dir; $log_file"
if [ $ok -eq 1 ]; then
    printf '%s \e[0;34m==DONE==\e[0m\n' "$info"
    rm -rf $log_file
else
    printf '%s \e[1;31m==ERROR==\e[0m\n' "$info" 
fi


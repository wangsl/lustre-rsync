#!/bin/bash

source /share/apps/lustre-copy/common.sh

if [ "$USER" == "root" ]; then ulimit -n 1024000; fi

prefix=$(/usr/bin/mktemp --dry-run XXXXXXXX)

source_dir="$1"
target_dir="$2"

if [ ! -d "$source_dir" ]; then echo "source $source_dir is not a folder"; exit 1; fi

mkdir -p $target_dir || exit 1
if [ ! -d "$target_dir" ]; then echo "target $target_dir is not a folder"; exit 1; fi

lfs find "$source_dir" --maxdepth 1 | egrep -v ^${source_dir}$ > $tmp_dir/$prefix.full

if [ -s $tmp_dir/$prefix.full ]; then
    split --lines=$n_lines --suffix-length=8 --numeric-suffixes $tmp_dir/$prefix.full $tmp_dir/$prefix-
    
    for lst in $tmp_dir/$prefix-*; do
	{
	    while read -r line; do
		printf '/%s\n' "$(basename "$line")"
	    done < $lst
	} > $lst.tmp
	rm -rf $lst
	echo "$rsync_alias --files-from=$lst.tmp '$source_dir' '$target_dir' > $lst.log 2>&1 && rm -rf $lst.tmp $lst.log"
    done | $parallel --no-notice --jobs $n_jobs
fi

rm -rf $tmp_dir/$prefix.full

n_source=$(lfs find "$source_dir" --maxdepth 1 -type f | wc -l)
n_target=$(lfs find "$target_dir" --maxdepth 1 -type f | wc -l)

info="[$(date '+%Y-%m-%dT%H:%M:%S.%3N')] $(hostname); $source_dir ; $log_file"
if [ $n_source -eq $n_target ]; then
    printf '%s \e[0;34m==DONE==\e[0m\n' "$info"
else
    printf '%s \e[1;31m==ERROR==\e[0m\n' "$info" 
fi


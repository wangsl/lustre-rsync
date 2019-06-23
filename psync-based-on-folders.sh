#!/bin/bash

source /share/apps/lustre-copy/common.sh

if [ "$USER" == "root" ]; then ulimit -n 1024000; fi

source_dir="$1"

if [ ! -d "$source_dir" ]; then
    echo "source: $source_dir does not exist"
    exit 1
fi

target_dir="$(echo "$source_dir" | sed -e "s#^$source_prefix#$target_prefix#")"

declare -a dir_list
declare -a special_dir_list

i=0
j=0
while IFS= read -r line; do
    if [[ "$line" =~ \' ]]; then
	special_dir_list[$j]="$line"
	j=$((j+1))
    else
	dir_list[$i]="$line"
	i=$((i+1))
    fi
done < <(lfs find "$source_dir" -type d)

n_dirs=${#dir_list[@]}
if [ $n_dirs -lt $n_jobs ]; then n_jobs=$n_dirs; fi

{
    for((i=0; i<$n_dirs; i++)); do
	target="$(echo "${dir_list[$i]}" | sed -e "s#^$source_prefix#$target_prefix#")"
	mkdir -p "$target"
	echo $rsync_non_recursive "'${dir_list[$i]}'" "'$target'"
    done
} | $parallel --no-notice --jobs $n_jobs

n_dirs=${#special_dir_list[@]}
j=0
for((i=0; i<$n_dirs; i++)); do
    target="$(echo "${special_dir_list[$i]}" | sed -e "s#^$source_prefix#$target_prefix#")"
    mkdir -p "$target"
    $rsync_non_recursive "${special_dir_list[$i]}" "$target" > /dev/null 2>&1 &
    j=$((j+1))
    if [ $j -eq $n_jobs ]; then j=0; wait; fi
done

wait

n_source=$(lfs find "$source_dir" | wc -l)
n_target=$(lfs find "$target_dir" | wc -l)

echo
echo "n_source: $n_source"
echo "n_target: $n_target"
echo

if [[ $n_source -gt 0 ]] && [[ $n_source -eq $n_target ]]; then
    printf '\e[1;34m%s\e[0m\n' "File copy finished successfully"
else
    printf '\e[1;31m%s\e[0m\n' "File copy exit with error"
fi
echo




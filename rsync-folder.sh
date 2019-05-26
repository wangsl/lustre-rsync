#!/bin/bash

source /share/apps/lustre-copy/common.sh

function _rsync_folder_recursive()
{
    local source_dir="$1"
    
    if [ ! -d "$source_dir" ]; then
	echo "source: $source_dir does not exit"
	exit
    fi
    
    declare -a source_dirs
    declare -a target_dirs

    local i=0
    while read -r line; do
	source_dirs[$i]="$line"
	target_dirs[$i]="$(echo "$line" | sed -e "s#^$source_prefix#$target_prefix#")"
	$psync_based_on_files "${source_dirs[$i]}" "${target_dirs[$i]}"
	i=$((i+1))
    done < <(lfs find "$source_dir" -type d)
    
    for((j=0; j<2; j++)); do
	for((i=0; i<${#source_dirs[@]}; i++)); do
	    echo -n "."
	    $rsync_alias "${source_dirs[$i]}" "$(dirname ${target_dirs[$i]})" > /dev/null 2>&1
	done
	echo
    done

    local target_dir="$(echo "$source_dir" | sed -e "s#^$source_prefix#$target_prefix#")"

    local n_source=$(lfs find "$source_dir" | wc -l)
    local n_target=$(lfs find "$target_dir" | wc -l)

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
}

function usage()
{
    echo "$0: usage --files|--folders source_dir"
}

if [ $# -ne 2 ]; then
    usage
    exit 1
fi

if [ "$1" == "--files" ]; then
    _rsync_folder_recursive "$2"
elif [ "$1" == "--folders" ]; then
    $psync_based_on_folders "$2"
else
    usage
    exit 1
fi

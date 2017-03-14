#!/bin/bash
pathToTar="/shares/data/backups/"
pathToFiles="/home/carl/bin"
prefix="bin_bkup-"
suffix=".tar.gz"
timestamp="$(date +'%Y%m%d%H%M%S')"
tarname="${pathToTar}${prefix}${timestamp}${suffix}"
tar -cvzf "${tarname}" "${pathToFiles}"

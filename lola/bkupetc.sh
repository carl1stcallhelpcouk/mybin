#!/bin/bash
pathToTar="/shares/data/backups/"
pathToFiles="/etc"
prefix="etc_bkup-"
suffix=".tar.gz"
timestamp="$(date +'%Y%m%d%H%M%S')"
tarname="${pathToTar}${prefix}${timestamp}${suffix}"
tar -cvzf "${tarname}" "${pathToFiles}"

# /bin/env bash
#set -x
DISK="${1}"
sync
#sudo umount --all-targets "${DISK}?"
#printf "DISK :- %s       running :- %s\n" "${DISK}" "mount | awk '{if ($1 == "'"${DISK}"'") print $3;}'"
sudo umount -v $( mount | awk '{if ($1 == "'"${DISK}"'") print $3;}' )
#sudo udisksctl unmount -b "${DISK}"
sudo udisksctl power-off --block-device "${DISK}"

#! /bin/sh

while [ 1 -eq 1 ] 
do
    curl -s -o "/dev/null" $1
    ret=$?

    if [ ${ret} -ne 0 ] ; then

        printf "%s\n" "Error occurred getting URL $1:${ret}:" > $2

        if [ ${ret} -eq 6 ]; then
            printf "%s\n" "Unable to resolve URL $1:${ret}" > $2
        fi

        if [ ${ret} -eq 7 ]; then
            printf "%s\n" "Unable to connect to URL $1:${ret}" > $2
        fi
        ex=1
    else
        printf "%s\n" "Site $1 is available" > $2
        ex=0
    fi
done
exit ${ex}
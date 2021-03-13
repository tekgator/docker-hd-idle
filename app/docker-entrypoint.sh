#!/bin/bash
set -e

CONFIG_FILENAME="hd-idle.config"

if [ ! -f $CONFIG_FILENAME ]; then
    HD_IDLE_OPTS=

    if [ ! -z "$IDLE_TIME" ]; then
        HD_IDLE_OPTS="$HD_IDLE_OPTS -i $IDLE_TIME"
    fi

    for (( i=1 ; ; i++ )); do
        n="DISK_ID${i}"
        declare -n DISK_IDX="$n"
        [ "${DISK_IDX+x}" ] || break

        m="IDLE_TIME${i}"
        declare -n IDLE_TIMEX="$m"
        IDLE_TIMEX=${IDLE_TIMEX:-60}
        
        HD_IDLE_OPTS="$HD_IDLE_OPTS -a $DISK_IDX -i $IDLE_TIMEX"
    done

    LOGGING=${LOGGING:-0}
    if [ "$LOGGING" != "0" ]; then
        HD_IDLE_OPTS="$HD_IDLE_OPTS -l $CONFIG_PATH/hd-idle.log"
    fi

    HD_IDLE_OPTS=${HD_IDLE_OPTS## } # remove leading spaces
    HD_IDLE_OPTS=${HD_IDLE_OPTS%% } # remove trailing spaces

    if [ -z "$HD_IDLE_OPTS" ]; then
        cp -v /etc/default/hd-idle ./$CONFIG_FILENAME
    else
        echo START_HD_IDLE=true > ./$CONFIG_FILENAME
        echo HD_IDLE_OPTS="\"$HD_IDLE_OPTS\"" >> ./$CONFIG_FILENAME
    fi

    chmod -v ug+rwx ./$CONFIG_FILENAME
    chown -v root:users ./$CONFIG_FILENAME

    echo "Created '$CONFIG_PATH/$CONFIG_FILENAME' file with content:"
    cat ./$CONFIG_FILENAME
fi

source ./$CONFIG_FILENAME
echo "Run hd-idle"
echo $START_HD_IDLE
echo $HD_IDLE_OPTS
hd-idle -d
echo "After hd-idle"

trap : TERM INT; sleep infinity & wait

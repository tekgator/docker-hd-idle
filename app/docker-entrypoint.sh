#!/bin/bash
set -e

if [ ! -f ./hd-idle.config ]; then
    cp $APP_PATH/hd-idle.config .
    
    HD_IDLE_OPTS=

    [ ! -z "$IDLE_TIME" ] && HD_IDLE_OPTS="$HD_IDLE_OPTS -i $IDLE_TIME"

    for (( i=1 ; ; i++ )); do
        n="DISK_ID${i}"
        declare -n DISK_IDX="$n"
        [ "${DISK_IDX+x}" ] || break

        m="IDLE_TIME${i}"
        declare -n IDLE_TIMEX="$m"
        IDLE_TIMEX=${IDLE_TIMEX:-600}

        HD_IDLE_OPTS="$HD_IDLE_OPTS -a $DISK_IDX -i $IDLE_TIMEX"

        o="DISK_CMD${i}"
        declare -n DISK_CMDX="$o"

        [ ! -z "$DISK_CMDX" ] && HD_IDLE_OPTS="$HD_IDLE_OPTS -c ${DISK_CMDX,,}"
    done

    HD_IDLE_OPTS=${HD_IDLE_OPTS## } # remove leading spaces
    HD_IDLE_OPTS=${HD_IDLE_OPTS%% } # remove trailing spaces

    # write HD_IDLE_OPTS to file
    echo HD_IDLE_OPTS="\"$HD_IDLE_OPTS\"" >> ./hd-idle.config
    chmod -v ug+rwx ./hd-idle.config
    chown -v root:users ./hd-idle.config

    echo "Created '$CONFIG_PATH/$CONFIG_FILENAME' file with content:"
    
    echo
    echo "BEGIN-----------------------------------------------------"
    echo
    
    cat ./hd-idle.config 

    echo
    echo "END-------------------------------------------------------"
    echo

    HD_IDLE_OPTS=
fi

source ./hd-idle.config

echo "Run hd-idle with options:"
echo "HD_IDLE_OPTS=$HD_IDLE_OPTS"

if [[ "$LEGACY" == "1" ]]; then
    echo "Running legacy version of hd-idle: http://hd-idle.sourceforge.net/"
    echo
    hd-idle.legacy -d $HD_IDLE_OPTS
else
    echo "Running golang version of hd-idle: https://github.com/adelolmo/hd-idle"
    echo
    hd-idle -d $HD_IDLE_OPTS
fi
#!/bin/bash
# sourcecode:     https://github.com/kvaps/fake-systemd
# upper vars:     like UNIT* are in exec_action context
# lower vars:     in local function
# camelcase vars: systemd params var

function exit_if_fail() {
    rlt_code=$1
    fail_msg=$2
    if [ $rlt_code -ne 0 ]; then
      echo -e "错误码: ${rlt_code}\n${fail_msg}"
      # read -s -n1 -p "按任意键退出"
      exit $rlt_code
    fi
}

function get_unit_file(){
    for dir in ${UNIT_PATHS[@]} ; do
        if [ -f "${dir}${UNIT}" ] ; then
            echo "${dir}${UNIT}"
            break
        fi
        if [ -f "${dir}${UNIT}.service" ] ; then
            echo "${dir}${UNIT}.service"
            break
        fi
    done
}

function read_option(){
    local option="$1"

    value="$(grep '^'$option'[= ]' "$UNIT_FILE" | cut -d '=' -f2- | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
    value="`
        echo $value |
        sed -e "s/%[i]/$UNIT_INSTANCE/g" \
            -e "s/%[I]/\"$UNIT_INSTANCE\"/g" \
            -e "s/%[n]/$UNIT_FULL/g" \
            -e "s/%[N]/\"$UNIT_FULL\"/g"
    `"
    # TODO: Add more options from:
    # https://www.freedesktop.org/software/systemd/man/systemd.unit.html#Specifiers

    if [ -n "$value" ]; then
        echo $value
        return
    else
        for include in $(grep '^.include' "$UNIT_FILE" | sed 's/^\.include[[:space:]]*//'); do
            recurse_value=$(UNIT_FILE=$include read_option $option)
            if [ -n "$recurse_value" ]; then
                echo $recurse_value
                return
            fi
        done
    fi

}

function read_multioption(){
    local option="$1"

    while IFS= read -r line; do
        echo "$line" |
            sed -e "s/%[i]/$UNIT_INSTANCE/g" \
                -e "s/%[I]/\"$UNIT_INSTANCE\"/g" \
                -e "s/%[n]/$UNIT_FULL/g" \
                -e "s/%[N]/\"$UNIT_FULL\"/g"
    done < <( sed ':a;N;$!ba;s/\\[[:space:]]*\n//g' "$UNIT_FILE" | grep '^'$option'[= ]' | cut -d '=' -f2- | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' )

    # TODO: Add more options from:
    # https://www.freedesktop.org/software/systemd/man/systemd.unit.html#Specifiers
}

function get_unit_wants() {
    sort -u <<< `(
        # Print wants from UNIT_PATHS
        for DIR in ${UNIT_PATHS[@]} ; do
            if [ -d "${DIR}${UNIT}.wants" ] ; then
                ls -1 "${DIR}${UNIT}.wants/" | tr '\n' ' '
            fi
        done
    
        # Print wants from unit-file
        read_option Wants $UNIT_FILE
    )`
}

function action_start(){
    # Start depended services
    for unit in ${UNIT_WANTS[@]}; do
        exec_action start $unit
    done

    # Load options 
    local User=$(read_option User)
    local Type=$(read_option Type)
    local PIDFile=$(read_option PIDFile)
    local EnvironmentFile=$(read_option EnvironmentFile | sed 's/^-//')
    local WorkingDirectory=($(read_option WorkingDirectory))
    local ExecStart=($(read_option ExecStart))
    local ExecStartPre=$(read_multioption ExecStartPre)
    local ExecStartPost=$(read_multioption ExecStartPost)
    local Environment=$(read_multioption Environment)

    ExecStart=`echo $ExecStart         |sed 's/^-\//\//'`
    ExecStartPre=`echo $ExecStartPre   |sed 's/^-\//\//'`
    ExecStartPost=`echo $ExecStartPost |sed 's/^-\//\//'`

    # export Environnement
    for envvar in $Environment; do
        eval $(echo "export $envvar")
    done

    # From doc: oneshot are the only service units that may have more than one
    # ExecStart= specified. They will be executed in order until either they
    # are all successful or one of them fails.
    # Note that systemd will consider the unit to be in the state "starting"
    # until the program has terminated, so ordered dependencies will wait 
    # for the program to finish before starting themselves. The unit will 
    # revert to the "inactive" state after the execution is done, never
    # reaching the "active" state. That means another request to start
    # the unit will perform the action again.
    if [[ "${Type,,}" == *"oneshot"* ]]; then
        local ExecStart=$(read_multioption ExecStart)

        while IFS=$'\n' read -a i; do
            # ignore errors
            $(eval echo "$i") || echo
        done  <<< "${ExecStartPre[@]}"

        while IFS=$'\n' read -a i; do
            # ignore errors
            $(eval echo "$i") || echo
        done  <<< "${ExecStart[@]}"

        while IFS=$'\n' read -a i; do
            $(eval echo "$i")
        done  <<< "${ExecStartPost[@]}"
    elif [ -z $Type ] || [[ "${Type,,}" == *"simple"* ]] || [[ "${Type,,}" == *"notify"* ]] || [[ "${Type,,}" == *"forking"* ]] ; then

        makepid=""
        if [ -z "$PIDFile" ]; then
            PIDdir="/run/${UNIT_NAME}"

            mkdir -p $PIDdir
            [ -n "$User" ] && chown $User $PIDdir
            PIDFile="${PIDdir}/${UNIT_NAME}.pid" 
            # makepid="--make-pidfile"
            makepid="-m"
        fi

        [ -f "$EnvironmentFile" ] && source "$EnvironmentFile"

        # cmd=("/usr/bin/start-stop-daemon --background --start --pidfile $PIDFile $makepid")
        cmd=("/usr/bin/start-stop-daemon -b -S -p $PIDFile $makepid")

        [ -f "$WorkingDirectory" ] && cmd+=("--chdir $WorkingDirectory")
        [ -n "$User" ] && cmd+=("--chuid $User")

        # cmd+=(--exec "${ExecStart[0]}" -- "${ExecStart[@]:1}")
        cmd="$cmd -x \"${ExecStart[0]}\" -- ${ExecStart[@]:1}"

        echo "正在运行前置进程: ${ExecStartPre}"
        # ${ExecStartPre}
        echo $ExecStartPre>/tmp/tmpcmd.rc
        . /tmp/tmpcmd.rc
        exit_if_fail $? "前置进程运行失败"
        # while IFS=$'\n' read -a i; do
        #     # ignore errors
        #     $(eval echo "$i") || echo
        # done  <<< "${ExecStartPre[@]}"

        echo "正在启动服务进程: ${cmd}"
        # eval "$(echo "${cmd[@]}")"
        # eval ${cmd[@]}
        # eval "$(echo "${cmd[@]}")"
        # ${cmd}
        echo $cmd>/tmp/tmpcmd.rc
        . /tmp/tmpcmd.rc
        exit_if_fail $? "服务进程启动失败"

        echo "正在运行后置进程: ${ExecStartPost}"
        # ${ExecStartPost}
        echo $ExecStartPost>/tmp/tmpcmd.rc
        . /tmp/tmpcmd.rc
        exit_if_fail $? "后置进程运行失败"
        # while IFS=$'\n' read -a i; do
        #     # ignore errors
        #     $(eval echo "$i") || echo
        # done  <<< "${ExecStartPost[@]}"
    else
        >&2 echo "Unknown service type $Type"
    fi
}

function action_stop(){
    # Load options 
    local User=$(read_option User)
    local Type=$(read_option Type)
    local PIDFile=$(read_option PIDFile)
    local EnvironmentFile=$(read_option EnvironmentFile | sed 's/^-//')
    local ExecStop=$(read_option ExecStop)
    local ExecStopPre=$(read_multioption ExecStopPre)
    local ExecStopPost=$(read_multioption ExecStopPost)
    local Environment=$(read_multioption Environment)

    ExecStop=`echo $ExecStop         |sed 's/^-\//\//'`
    ExecStopPre=`echo $ExecStopPre   |sed 's/^-\//\//'`
    ExecStopPost=`echo $ExecStopPost |sed 's/^-\//\//'`

    [ -z "$PIDFile" ] && PIDFile="/run/${UNIT_NAME}/${UNIT_NAME}.pid"
    [ -f "$EnvironmentFile" ] && source "$EnvironmentFile"

    # export Environnement
    for envvar in $Environment; do
        eval $(echo "export $envvar")
    done


    # Stop service 
    if [ -z "$ExecStop" ] ; then
        cmd="/usr/bin/start-stop-daemon --stop --pidfile $PIDFile"
        [ -n "$User" ] && cmd+=("--chuid $User")
    else
        cmd="$ExecStop"
        [ -n "$User" ] && cmd="runuser -m -u $User -- $cmd"
    fi


    while IFS=$'\n' read -a i; do
        # ignore errors
        $(eval echo "$i") || echo
    done  <<< "${ExecStopPre[@]}"

    # eval "$(echo "${cmd[@]}")"
    cmd="${cmd[@]}"
    echo $cmd
    $cmd
    exit_if_fail $? "无法停止服务进程，服务可能未启动。若服务正在运行，请使用kill指令手动杀掉服务进程!"

    while IFS=$'\n' read -a i; do
        # ignore errors
        $(eval echo "$i") || echo
    done  <<< "${ExecStopPost[@]}"
}

function action_restart(){
    action_stop
    sleep 1
    action_start
}

function action_enable(){
    local WantedBy=$(read_option WantedBy)

    if [ -z $WantedBy ] ; then
        >&2 echo "Unit $UNIT have no WantedBy option."
        exit 1
    fi
    
    local WANTEDBY_DIR="/etc/systemd/system/$WantedBy.wants"

    if [ ! -f "$WANTEDBY_DIR/$UNIT_FULL" ] ; then
        mkdir -p $WANTEDBY_DIR
        echo Created symlink from $WANTEDBY_DIR/$UNIT_FULL to $UNIT_FILE.
        ln -s $UNIT_FILE $WANTEDBY_DIR/$UNIT_FULL
    fi
}
    
function action_disable(){
    local WantedBy=$(read_option WantedBy)

    if [ -z $WantedBy ] ; then
        >&2 echo "Unit $UNIT have no WantedBy option."
        exit 1
    fi

    local WANTEDBY_DIR="/etc/systemd/system/$WantedBy.wants"

    if [ -f "$WANTEDBY_DIR/$UNIT_FULL" ] ; then
        echo Removed $WANTEDBY_DIR/$UNIT_FULL.
        rm -f $WANTEDBY_DIR/$UNIT_FULL
        rmdir --ignore-fail-on-non-empty $WANTEDBY_DIR
    fi
}

function action_isenabled(){
    local WantedBy=$(read_option WantedBy)

    if [ -z $WantedBy ] ; then
        echo "unknown"
    else
        local WANTEDBY_DIR="/etc/systemd/system/$WantedBy.wants"
        if [ -f "$WANTEDBY_DIR/$UNIT_FULL" ] ; then
            echo "enabled"
            exit 0
        else
            echo "disabled"
            exit 1
        fi
    fi
}

function action_isactive(){
    pid=$(_get_pid)

    # set default pifile
    [ "$pid" == "-1" ] && echo "unknown" && exit 3

    # check if the pid exists - systemctl returns 3
    kill -0 $pid > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "active"
        exit 0
    else
        echo "failed"
        exit 3
    fi
}

function _get_pid(){
    local PIDFile=$(read_option PIDFile)

    # set default pifile
    [ -z "$PIDFile" ] && PIDFile="/run/${UNIT_NAME}/${UNIT_NAME}.pid"

    # now check if the pidfile exists
    if [ ! -f "$PIDFile" ]; then
        echo "-1"
    else
        cat $PIDFile
    fi
}

function action_status(){
    local Description=$(read_option Description)
    local Documentation=$(read_option Documentation)
    pid=$(_get_pid)
    isenabled=$(action_isenabled)
    isactive=$(action_isactive)
    status="inactive (dead)"
    if [ $isactive == "failed" ]; then
        status="failed (Result: not_implemented)"
    elif [ $isactive == "active" ]; then
        psdate=$(ps -p $pid -o lstart=)
        pscmd=($(ps -p $pid -o cmd=))
        psmem=$(ps -p $pid -o %mem= | tr -d ' ')
        status="active (running) since $psdate"
    fi

    echo "● $UNIT - $Description"
    echo "   Loaded: loaded ($UNIT_FILE; $isenabled; vendor preset: not_implemented)"
    echo "   Active: $status"
    if [ $isactive == "active" ]; then
        if [ ! -z $Documentation ]; then
          echo "     Docs: $Documentation"
        fi
        echo " Main PID: $pid ($(basename ${pscmd[0]}))"
        echo "   Memory: $psmem%"
        echo "   CGroup: /system.slice/$UNIT"
        echo "           └─$pid ${pscmd[@]}"
    fi
    echo
}

function exec_action(){
    local ACTION=$1
    local UNIT=$2

    [[ $UNIT =~ '.' ]] || UNIT="$UNIT.service"

    local UNIT_NAME=$(echo $UNIT | cut -d '.' -f1)

    if [[ $UNIT =~ '@' ]] ; then
        local UNIT_INSTANCE=`echo $UNIT | cut -d'@' -f2- | cut -d. -f1`
        local UNIT=`echo $UNIT | sed "s/$UNIT_INSTANCE//"`
    fi

    local UNIT_FILE=`get_unit_file $UNIT`
    local UNIT_FULL=`echo $UNIT | sed "s/@/@$UNIT_INSTANCE/"`
    local UNIT_WANTS=(`get_unit_wants $UNIT`)

    # Systemd env variables
    # https://www.freedesktop.org/software/systemd/man/systemd.service.html
    local MAINPID=$(_get_pid)

    if [ -z $UNIT_FILE ] ; then
        >&2 echo "Failed to $ACTION $UNIT: Unit $UNIT not found."
        exit 1
    else
        case "$ACTION" in
            status )    action_status ;;
            start )     action_start ;;
            stop )      action_stop ;;
            restart )   action_restart ;;
            enable )    action_enable ;;
            disable )   action_disable ;;
            is-active ) action_isactive ;;
            is-enabled ) action_isenabled ;;
            # exit 0 if unknown operation to avoid errors
            # like mask, unmask etc
            * ) >&2 echo "Unknown operation '$ACTION'" ; exit 0 ;;
        esac
    fi
}

function main(){

    local USAGE='systemctl [OPTIONS...] {COMMAND} ...

Query or send control commands to the systemd manager.

  -h --help           Show this help

Unit Commands:
  start NAME...                   Start (activate) one or more units
  stop NAME...                    Stop (deactivate) one or more units
  restart NAME...                 Start or restart one or more units
  is-active PATTERN...            Check whether units are active
  status [PATTERN...|PID...]      Show runtime status of one or more units

Unit File Commands:
  enable NAME...                  Enable one or more unit files
  disable NAME...                 Disable one or more unit files
  is-enabled NAME...              Check whether unit files are enabled
'

    local ACTION="$1"
    local UNITS="${@:2}"
    local UNIT_PATHS=(
        /etc/systemd/system/
        /usr/lib/systemd/system/
    )

    echo "service文件搜索路径："
    for tmp_path in ${UNIT_PATHS[@]}; do
        echo $tmp_path
    done
    echo ""


    case "$ACTION" in
        help ) >&2 echo "This command expects one or more unit names. Did you mean --help?" ; exit 1 ;;
        -h ) echo "$USAGE" ; exit 0 ;;
        --help ) echo "$USAGE" ; exit 0 ;;
    esac

    for UNIT in ${UNITS[@]}; do
        exec_action $ACTION $UNIT
    done
}

main $@

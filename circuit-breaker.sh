#!/bin/bash
PROCESS=prterun
PID=$(ps x -o pid,command | grep -v "grep" | grep -e "$PROCESS" | awk '{printf "%d ", $1}')
COMMAND=$(ps x -o command | grep -v "grep" | grep -e "$PROCESS" | awk "NR==1 {print}")
COUNT=0
ESC=$(printf "\033")
CPU_Temp() {
    case $(ps x -o command | grep -v "grep" | grep -e "$PROCESS" | wc -l) in
	0)
	    ;;
	*)
	    echo "$(sensors | grep Tctl | sed s/Tctl/CPU/g)"
	    ;;
    esac
}
Show_Time() {
    case $COUNT in
	360)
	    echo "$(($COUNT/12)) minutes"
	    ;;
	*)
	    echo "$(($COUNT/720)) hours $(($COUNT%720/12)) minutes"
	    ;;
    esac
}
BREAKER() {
    if [[ -n $(sensors | grep Tctl | grep -e "+[1][0][2-9].[0-9]" -e "+[1][1][0-9].[0-9]") ]]; then
	echo "Overheat! ($ESC[31m$(sensors | grep Tctl | awk '{print $2}')$ESC[m)"
	echo "Killing $(ps x -o command | grep -v "grep" | grep $PROCESS | awk 'NR==1 {print}')..."
	kill -9 $(echo $PID)
    fi
}

if [[ -n $(ps x -o command | grep -v "grep" | grep $PROCESS) ]]; then
    while [[ -n $(ps x -o command | grep -v "grep" | grep $PROCESS) ]]; do
	case $COUNT in
	    0)
		echo "The process to be monitored is"
		echo "$(printf "\t")\"$ESC[31m$COMMAND$ESC[m\"."
		echo "Check CPU temperature every 5 seconds."
		;;
	    *)
		;;
	esac
	sleep 5
	((COUNT += 1))
	if [[ $COUNT -le 240 ]]; then
	    BREAKER
	    if [[ $COUNT -lt 3 ]]; then
		CPU_Temp
	    else
		case $(($COUNT % 3)) in
		    0)
			CPU_Temp
			case $(($COUNT % 60)) in
			    0)
				echo "$(($COUNT/12)) minutes"
				case $COUNT in
				    240)
					echo "From now on, check CPU temperature once every 10 minutes."
					;;
				    *)
					;;
				esac
				;;
			    *)
				;;
			esac
		esac
	    fi
	else
	    case $(($COUNT % 120)) in
		0)
		    BREAKER
		    CPU_Temp
		    case $(($COUNT % 360)) in
			0)
			    Show_Time
			    ;;
			*)
			    ;;
		    esac
		    ;;
		*)
		    ;;
	    esac
	fi
    done
    echo "Process"
    echo "$(printf "\t")\"$ESC[31m$COMMAND$ESC[m\""
    echo "$(printf "\t\t")is finished."
else  
    echo "The specified process has ended or has not started."
fi

#!/bin/bash
PROCESS=prterun
CPU_Temp() {
    echo "$(sensors | grep Tctl | sed s/Tctl/CPU/g)"
}
Show_Time() {
    if [[ $COUNT -lt 720 ]]; then
	echo "$(($COUNT/12)) minutes"
    else
	echo "$(($COUNT/720)) hours $(($COUNT%720/12)) minutes"
    fi
}
BREAKER() {
    if [[ -n $(sensors | grep Tctl | grep -e "+[1][0][2-9].[0-9]" -e "+[1][1][0-9].[0-9]") ]]; then
	echo "Overheat! ($(echo $(sensors | grep Tctl | sed s/"Tctl: "//g)))"
	echo "Killing $PROCESS..."
	pkill $PROCESS
    fi
}

while [[ -n $(ps x | grep -v "grep" | grep -e "$PROCESS") ]]; do
    sleep 5
    ((COUNT += 1))
    if [[ $COUNT -le 240 ]]; then
	BREAKER
	if [[ $COUNT -lt 3 ]]; then
	    CPU_Temp
	elif [[ $(($COUNT % 3)) -eq 0 ]]; then
	    CPU_Temp
	    if [[ $(($COUNT % 60)) -eq 0 ]]; then
		echo "$(($COUNT/12)) minutes"
		if [[ $COUNT -eq 240 ]]; then
		    echo "From now on, check the temperature once every 10 minutes."
		fi
	    fi
	fi
    else
	if [[ $(($COUNT % 120)) -eq 0 ]]; then
	    BREAKER
	    CPU_Temp
	    if [[ $(($COUNT % 360)) -eq 0 ]]; then
		Show_Time
	    fi
	fi
    fi
done

if [[ -z $(ps x | grep -v "grep" | grep -e "$PROCESS") ]]; then
    echo "$(ps x -o command | grep $PROCESS) ended."
fi


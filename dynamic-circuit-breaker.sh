#!/usr/bin/env bash
PROCESS="$*"
EXCLUDE="$0 $*"
SCAN_PROCESS_W_PID() {
    ps x -o pid,command | grep -v "grep" | grep -v "${EXCLUDE}" | grep -e "${PROCESS}"
}
SCAN_POST() {
    case $(PROCESS_NUM) in
	0)
	    ;;
	*)		
	    POST_PROCESS_NUM=$(ps x -o command | grep -v "grep" | grep -v "${EXCLUDE}" | grep -e "${PROCESS}" | wc -l)
	    POST_COMMAND_W_PID=$(ps x -o pid,command | grep -v "grep" | grep -v "${EXCLUDE}" | grep -e "${PROCESS}")
	    ;;
    esac
}
PROCESS_NUM() {
    ps x -o command | grep -v "grep" | grep -v "${EXCLUDE}" | grep -e "${PROCESS}" | wc -l
}
SCAN_PID() {
    echo "$(ps x -o pid,command | grep -v "grep" | grep -v "${EXCLUDE}" | grep -e "${PROCESS}" | awk '{printf "%d ", $1}')"
}
DIFF_PROCESS_BEFORE() {
    diff <(echo "${COMMAND_W_PID}") <(echo "${POST_COMMAND_W_PID}") | grep -e "<"
}
DIFF_PROCESS_NUM_BEFORE() {
    diff <(echo "${COMMAND_W_PID}") <(echo "${POST_COMMAND_W_PID}") | grep -e "<" | wc -l
}
DIFF_PROCESS_AFTER() {
    diff <(echo "${COMMAND_W_PID}") <(echo "${POST_COMMAND_W_PID}") | grep -e ">"
}
DIFF_PROCESS_NUM_AFTER() {
    diff <(echo "${COMMAND_W_PID}") <(echo "${POST_COMMAND_W_PID}") | grep -e ">" | wc -l
}
CPU_TEMP() {
    echo "$(sensors | grep Tctl | sed s/Tctl/CPU/g | awk '{printf "%s %s", $1, $2}' )"
}
PRE_COMMAND_OUT() {
    for i in $(seq 1 ${PRE_PROCESS_NUM}); do
	case $i in
	    1)
		printf "\t\"${ESC}[31m$(echo "${COMMAND_W_PID}" | awk "NR==1" | awk '{for(i=2;i<NF;i+=1){printf "%s ", $i}printf $NF}')${ESC}[m"
		case ${PRE_PROCESS_NUM} in
		    1)
			echo "\"."
			;;
		    *)
			printf "\n"
			;;
		esac
		;;
	    ${PRE_PROCESS_NUM})
		echo "${TAB} ${ESC}[31m$(echo "${COMMAND_W_PID}" | awk "NR==$i" | awk '{for(i=2;i<NF;i+=1){printf "%s ", $i}printf $NF}')${ESC}[m\"."
		;;
	    *)
		echo "${TAB} ${ESC}[31m$(echo "${COMMAND_W_PID}" | awk "NR==$i" | awk '{for(i=2;i<NF;i+=1){printf "%s ", $i}printf $NF}')${ESC}[m"
		;;
	esac
    done
}
POST_COMMAND_OUT() {
    for i in $(seq 1 ${POST_PROCESS_NUM}); do
	case $i in
	    1)
		printf "\t\"${ESC}[31m$(echo "${POST_COMMAND_W_PID}" | awk "NR==1" | awk '{for(i=2;i<NF;i+=1){printf "%s ", $i}printf $NF}')${ESC}[m"
		case ${POST_PROCESS_NUM} in
		    1)
			echo "\""
			;;
		    *)
			printf "\n"
			;;
		esac
		;;
	    ${POST_PROCESS_NUM})
		echo "${TAB} ${ESC}[31m$(echo "${POST_COMMAND_W_PID}" | awk "NR==$i" | awk '{for(i=2;i<NF;i+=1){printf "%s ", $i}printf $NF}')${ESC}[m\""
		;;
	    *)
		echo "${TAB} ${ESC}[31m$(echo "${POST_COMMAND_W_PID}" | awk "NR==$i" | awk '{for(i=2;i<NF;i+=1){printf "%s ", $i}printf $NF}')${ESC}[m"
		;;
	esac
    done
}
POST_PROCESS() {
    if [[ ${COMMAND_W_PID} != ${POST_COMMAND_W_PID} ]]; then
	case $(DIFF_PROCESS_NUM_BEFORE) in
	    0)
	        ;;
	    *)
		case $(DIFF_PROCESS_NUM_BEFORE) in
		    1)
			echo "The following process has been terminated during monitoring for some reason."
			;;
		    *)
			echo "The following processes have been terminated during monitoring for some reason."
			;;
		esac
		for i in $(seq 1 $(DIFF_PROCESS_NUM_BEFORE)); do
		    case $i in
			1)
			    printf "\t\"${ESC}[31m$(echo "$(DIFF_PROCESS_BEFORE)" | awk "NR==1" | awk '{for(i=3;i<NF;i+=1){printf "%s ", $i}printf $NF}')${ESC}[m"
			    case $(DIFF_PROCESS_NUM_BEFORE) in
				1)
				    echo "\""
				    ;;
				*)
				    printf "\n"
				    ;;
			    esac			
			    ;;
			"$(DIFF_PROCESS_NUM_BEFORE)")
			    echo "${TAB} ${ESC}[31m$(echo "$(DIFF_PROCESS_BEFORE)" | awk "NR==$i" | awk '{for(i=3;i<NF;i+=1){printf "%s ", $i}printf $NF}')${ESC}[m\""
			    ;;
			*)
			    echo "${TAB} ${ESC}[31m$(echo "$(DIFF_PROCESS_BEFORE)" | awk "NR==$i" | awk '{for(i=3;i<NF;i+=1){printf "%s ", $i}printf $NF}')${ESC}[m"
			    ;;
		    esac
		done
		;;
	esac
	case $(DIFF_PROCESS_NUM_AFTER) in
	    0)
	        ;;
	    *)
		case $(DIFF_PROCESS_NUM_BEFORE) in
		    0)
			case $(DIFF_PROCESS_NUM_AFTER) in
			    1)
				echo "The following process has been initiated during the monitoring."
				;;
			    *)
				echo "The following processes have been initiated during the monitoring."
				;;
			esac	
			;;
		    *)
			case $(DIFF_PROCESS_NUM_AFTER) in
			    1)
				echo "Also, the following process has been initiated during the monitoring."
				;;
			    *)
				echo "Also, the following processes have been initiated during the monitoring."
				;;
			esac
			;;
		esac
		for i in $(seq 1 $(DIFF_PROCESS_NUM_AFTER)); do
		    case $i in
			1)
			    printf "\t\"${ESC}[31m$(echo "$(DIFF_PROCESS_AFTER)" | awk "NR==1" | awk '{for(i=3;i<NF;i+=1){printf "%s ", $i} printf $NF}')${ESC}[m"
			    case $(DIFF_PROCESS_NUM_AFTER) in
				1)
				    echo "\""
				    ;;
				*)
				    printf "\n"
				    ;;
			    esac		    
			    ;;
			"$(DIFF_PROCESS_NUM_AFTER)")
			    echo "${TAB} ${ESC}[31m$(echo "$(DIFF_PROCESS_AFTER)" | awk "NR==$i" | awk '{for(i=3;i<NF;i+=1){printf "%s ", $i} printf $NF}')${ESC}[m\""
			    ;;
			*)
			    echo "${TAB} ${ESC}[31m$(echo "$(DIFF_PROCESS_AFTER)" | awk "NR==$i" | awk '{for(i=3;i<NF;i+=1){printf "%s ", $i} printf $NF}')${ESC}[m"
			    ;;
		    esac
		done
		;;
	esac
    fi
}
BREAKER() {
    if [[ -n $(sensors | grep Tctl | grep -e "+[1][0][2-9].[0-9]" -e "+[1][1][0-9].[0-9]") ]]; then
	echo "Overheat! (CPU: +${ESC}[31m$(echo "$(CPU_TEMP)" | awk '{printf substr($2, 2, length($2)-3)}')${ESC}[m°C)"
	kill -9 $(SCAN_PID)
    fi
}

###---------------SCRIPT_START---------------###

main() {
    ESC=$(printf "\033")
    TAB=$(printf "\t")
    if [[ -n $(SCAN_PROCESS_W_PID) && -n ${PROCESS} ]]; then
	COMMAND_W_PID=$(SCAN_PROCESS_W_PID)
	PRE_PROCESS_NUM=$(PROCESS_NUM)
	COUNT=0
	echo "This script is dynamic."
	echo "Please specify your process carefully."
	echo "I accept no responsibility for any losses caused by this script."
	while [[ -n $(SCAN_PROCESS_W_PID) ]]; do
	    case $COUNT in
		0)
		    case ${PRE_PROCESS_NUM} in
			1)
			    echo "The monitored process is"
			    ;;
			*)
			    echo "The monitored processes are"
			    ;;
		    esac
		    PRE_COMMAND_OUT
		    echo "Monitoring start..."
		    echo "Check CPU temperature every 5 seconds."
		    ;;
		*)
		    ;;
	    esac
	    SCAN_POST
	    sleep 5
	    ((COUNT += 1))
	    SCAN_POST
	    if [[ $COUNT -le 240 ]]; then
		BREAKER
		case $(PROCESS_NUM) in
		    0)
		        ;;
		    *)
			if [[ $COUNT -lt 3 ]]; then
			    CPU_TEMP
			else
			    case $(($COUNT % 3)) in
				0)
				    CPU_TEMP
				    case $(($COUNT % 60)) in
					0)
					    echo "$(($COUNT/12)) minutes"
					    ;;
					*)
					    ;;
				    esac
			    esac
			fi
			;;
		esac
	    else
		BREAKER
		case $(PROCESS_NUM) in
		    0)
		        ;;
		    *)
			case $(($COUNT % 120)) in
			    0)
				CPU_TEMP
				case $(($COUNT % 360)) in
				    0)
					case $(($COUNT / 360)) in
					    1)
						echo "$(($COUNT/12)) minutes"
						;;
					    *)
						echo "$(($COUNT/720)) hours $(($COUNT%720/12)) minutes"
						;;
					esac
					;;
				    *)
					;;
				esac
				;;
			    *)
				;;
			esac
			;;
		esac
	    fi
	done
	case ${POST_PROCESS_NUM} in
	    1)	    
		echo "The following process"
		;;
	    *)
		echo "The following processes"
		;;
	esac
	POST_COMMAND_OUT
	case ${POST_PROCESS_NUM} in
	    1)
		echo "${TAB}${TAB} has been terminated."
		;;
	    *)
		echo "${TAB}${TAB} have been terminated."
		;;
	esac
	POST_PROCESS
    else  
	echo "The process or processes containing the specified"
	echo "${TAB}\"${PROCESS}\""
	echo "${TAB}${TAB}have already been terminated or have not started yet."
    fi
    echo "Exiting..."
}

main

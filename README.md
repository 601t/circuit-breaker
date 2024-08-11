# Circuit Breaker Script
CPU temperature is checked every 5 seconds.<br>
If the CPU temperature exceeds the threshold, this script will forcefully terminate the specified command (which is believed to be the cause of the high temperature).<br>
This script has been tested with Bash 5.2.32 and Zsh 5.9 on Arch Linux.

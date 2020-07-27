#!/bin/bash

# Script: Monitor de placa Radeon RX 580 no Arch Linux
# Autor: Rodrigo Leutz


# Esta variavel não está funcionando corretamente.
# Precisa encontrar solução.
# funciona se fizer o seguinte comando: cp $PWD/dialogrc-rmonitor ~/.dialogrc
# DIALOGRC=$PWD/dialogrc-rmonitor

# Solução do dialogrc encontrada para copiar
if [ -f dialogrc-rmonitor ] && [ ! -f ~/.dialogrc ]
then
    cp dialogrc-rmonitor ~/.dialogrc
fi

trap ctrl_c INT

if [ $1 = "--help" ] || [ $1 = "-h" ]
then
	echo "Ajuda do Radeon Monitor"
	echo
	echo "rmonitor tempo  =  Seta o tempo em segundos do monitor"
	echo "rmonitor --help =  Mostra esse menu de ajuda"
	echo 
	echo "Tempo padrão 2 segundos"
	exit
fi

if [ $# -eq 1 ]
then
	TIME=$1
else
	TIME=2
fi

HWMON=1
check_hwmon() {
	while [ $HWMON -le 10 ]
	do
		if [ `cat /sys/class/hwmon/hwmon$HWMON/name` = "amdgpu" ]
		then
			break
		fi
		HWMON=`echo "$HWMON + 1"|bc`
	done
}

function ctrl_c() {
	setterm -cursor on
	clear
        echo "** Saiu do programa com ctrl+c"
	echo $HWMON
	exit
}
get_min() {
	if [ `echo "$1 < $2"|bc` -eq 1 ]
        then
                echo "$1"
	else
		echo "$2"
        fi
}
get_max() {
	if [ `echo "$1 > $2"|bc` -eq 1 ]
        then
		echo "$1"
	else
		echo "$2"
        fi
}

check_hwmon

GLXINFO=`glxinfo -B`
SENSORS=`sensors`

VGA=`echo "$GLXINFO" | grep Device | awk -F"(" '{print $1}' | awk -F: '{print $2}'`
VGA=`echo $VGA | sed 's/ *$//g'`
TEMPMAX=`echo "$SENSORS" | grep edge | awk -F+ '{ print $2 }' | awk -F° '{print $1}'`
FANMAX=`echo "$SENSORS" | grep fan1 | awk -F: '{print $2}' | awk -F"RPM" '{print $1}'`
FANMAX=`echo $FANMAX | sed 's/ *$//g'`
POWERMAX=`echo "$SENSORS" | grep power1 | awk -F: '{print $2}' | awk -F"W" '{print $1}'`
POWERMAX=`echo $POWERMAX | sed 's/ *$//g'`
TEMPMIN=`echo $TEMPMAX`
FANMIN=`echo $FANMAX`
POWERMIN=`echo $POWERMAX`
POWER=`echo $POWERMIN | sed 's/ *$//g'`
GPUCLOCKMIN=`cat /sys/class/hwmon/hwmon$HWMON/freq1_input`
GPUCLOCKMIN=`echo "$GPUCLOCKMIN / 1000000" | bc`
GPUCLOCKMAX=`echo $GPUCLOCKMIN`
GPUCLOCK=`echo $GPUCLOCKMIN`
MEMCLOCKMIN=`cat /sys/class/hwmon/hwmon$HWMON/freq2_input`
MEMCLOCKMIN=`echo "$MEMCLOCKMIN / 1000000" | bc`
MEMCLOCKMAX=`echo $MEMCLOCKMIN`
MEMCLOCK=`echo $MEMCLOCKMIN`
MEMFREE=`echo "$GLXINFO" | grep "Currently available dedicated video memory:" | awk -F: '{print $2}' | awk -F"MB" '{print $1}'`
MEMTOTAL=`echo "$GLXINFO" | grep "Dedicated video memory:" | awk -F: '{print $2}' | awk -F"MB" '{print $1}'`
MEMFREE=`echo $MEMFREE | sed 's/ *$//g'`
MEMTOTAL=`echo $MEMTOTAL | sed 's/ *$//g'`
MEMUSEMAX=`echo "$MEMTOTAL - $MEMFREE"|bc`
MEMUSEMIN=`echo "$MEMTOTAL - $MEMFREE"|bc`

while :; do
	GLXINFO=`glxinfo -B`
	SENSORS=`sensors`

	TEMP=`echo "$SENSORS" | grep edge | awk -F+ '{ print $2 }' | awk -F° '{print $1}'`
	FAN=`echo "$SENSORS" | grep fan1 | awk -F: '{print $2}' | awk -F"RPM" '{print $1}'`
	POWER=`echo "$SENSORS" | grep power1 | awk -F: '{print $2}' | awk -F"W" '{print $1}'`
	GPUCLOCK=`cat /sys/class/hwmon/hwmon$HWMON/freq1_input`
	GPUCLOCK=`echo "$GPUCLOCK / 1000000" | bc`
	MEMCLOCK=`cat /sys/class/hwmon/hwmon$HWMON/freq2_input`
	MEMCLOCK=`echo "$MEMCLOCK / 1000000" | bc`
	MEMFREE=`echo "$GLXINFO" | grep "Currently available dedicated video memory:" | awk -F: '{print $2}' | awk -F"MB" '{print $1}'`
	MEMFREE=`echo $MEMFREE | sed 's/ *$//g'`
	MEMUSE=`echo "$MEMTOTAL - $MEMFREE"|bc`
	POWER=`echo $POWER | sed 's/ *$//g'`
	FAN=`echo $FAN | sed 's/ *$//g'`
	TEMPMIN=`get_min $TEMP $TEMPMIN`
	TEMPMAX=`get_max $TEMP $TEMPMAX`
	FANMIN=`get_min $FAN $FANMIN`
	FANMAX=`get_max $FAN $FANMAX`
	POWERMIN=`get_min $POWER $POWERMIN`
	POWERMAX=`get_max $POWER $POWERMAX`
	GPUCLOCKMIN=`get_min $GPUCLOCK $GPUCLOCKMIN`
	GPUCLOCKMAX=`get_max $GPUCLOCK $GPUCLOCKMAX`
        MEMCLOCKMIN=`get_min $MEMCLOCK $MEMCLOCKMIN`
	MEMCLOCKMAX=`get_max $MEMCLOCK $MEMCLOCKMAX`
	MEMUSEMIN=`get_min $MEMUSE $MEMUSEMIN`
	MEMUSEMAX=`get_max $MEMUSE $MEMUSEMAX`
	dialog --colors --title "\Zb\Z1 $VGA " \
	--infobox "\n\ZB\ZnGPU Clock     : \Z2$GPUCLOCK \ZnMHz
	\nGPU Clock Min : \Z4$GPUCLOCKMIN \ZnMHz
        \nGPU Clock Max : \Z3$GPUCLOCKMAX \ZnMHz
	\nMem Clock     : \Z2$MEMCLOCK \ZnMHz
	\nMem Clock Min : \Z4$MEMCLOCKMIN \ZnMHz
        \nMem Clock Max : \Z3$MEMCLOCKMAX \ZnMHz
	\nMem Use       : \Z2$MEMUSE/$MEMTOTAL \ZnMB
	\nMem Use Min   : \Z4$MEMUSEMIN/$MEMTOTAL \ZnMB
        \nMem Use Max   : \Z3$MEMUSEMAX/$MEMTOTAL \ZnMB
	\nTemp          : \Z2$TEMP\Zn°C
	\nTemp Min      : \Z4$TEMPMIN\Zn°C
        \nTemp Max      : \Z3$TEMPMAX\Zn°C
	\nFan           : \Z2$FAN \ZnRPM
	\nFan Min       : \Z4$FANMIN \ZnRPM
        \nFan Max       : \Z3$FANMAX \ZnRPM
	\nPower         : \Z2$POWER \ZnW
	\nPower Min     : \Z4$POWERMIN \ZnW
        \nPower Max     : \Z3$POWERMAX \ZnW\n
        \n(\Z1Ctrl+c\Zn para Sair)" 23 40
	setterm -cursor off
	sleep "$TIME"
done

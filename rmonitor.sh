#!/bin/bash

# Script: Monitor de placa Radeon RX 580 no Arch Linux
# Autor: Rodrigo Leutz


# Esta variavel não está funcionando corretamente.
# Precisa encontrar solução.
# funciona se fizer o seguinte comando: cp $PWD/dialogrc-rmonitor ~/.dialogrc
# DIALOGRC=$PWD/dialogrc-rmonitor

# Solução do dialogrc encontrada para copiar
if [ -f dialogrc-rmonitor ] && [ ! -f .dialogrc ]
then
    cp dialogrc-rmonitor ~/.dialogrc
fi

trap ctrl_c INT

function ctrl_c() {
	setterm -cursor on
	clear
        echo "** Saiu do programa com ctrl+c"
	echo $DIALOGRC
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

VGA=`glxinfo -B | grep Device | awk -F"(" '{print $1}' | awk -F: '{print $2}'`
VGA=`echo $VGA | sed 's/ *$//g'`
TEMPMAX=`sensors | grep edge | awk -F+ '{ print $2 }' | awk -F° '{print $1}'`
FANMAX=`sensors | grep fan1 | awk -F: '{print $2}' | awk -F"RPM" '{print $1}'`
FANMAX=`echo $FANMAX | sed 's/ *$//g'`
POWERMAX=`sensors | grep power1 | awk -F: '{print $2}' | awk -F"W" '{print $1}'`
POWERMAX=`echo $POWERMAX | sed 's/ *$//g'`
TEMPMIN=`echo $TEMPMAX`
FANMIN=`echo $FANMAX`
POWERMIN=`echo $POWERMAX`
POWER=`echo $POWERMIN | sed 's/ *$//g'`
GPUCLOCKMIN=`cat /sys/class/hwmon/hwmon3/freq1_input`
GPUCLOCKMIN=`echo "$GPUCLOCKMIN / 1000000" | bc`
GPUCLOCKMAX=`echo $GPUCLOCKMIN`
GPUCLOCK=`echo $GPUCLOCKMIN`
MEMCLOCKMIN=`cat /sys/class/hwmon/hwmon3/freq2_input`
MEMCLOCKMIN=`echo "$MEMCLOCKMIN / 1000000" | bc`
MEMCLOCKMAX=`echo $MEMCLOCKMIN`
MEMCLOCK=`echo $MEMCLOCKMIN`
MEMFREE=`glxinfo -B | grep "Currently available dedicated video memory:" | awk -F: '{print $2}' | awk -F"MB" '{print $1}'`
MEMTOTAL=`glxinfo -B | grep "Dedicated video memory:" | awk -F: '{print $2}' | awk -F"MB" '{print $1}'`
MEMFREE=`echo $MEMFREE | sed 's/ *$//g'`
MEMTOTAL=`echo $MEMTOTAL | sed 's/ *$//g'`
MEMUSEMAX=`echo "$MEMTOTAL - $MEMFREE"|bc`
MEMUSEMIN=`echo "$MEMTOTAL - $MEMFREE"|bc`

while :; do
	TEMP=`sensors | grep edge | awk -F+ '{ print $2 }' | awk -F° '{print $1}'`
	FAN=`sensors | grep fan1 | awk -F: '{print $2}' | awk -F"RPM" '{print $1}'`
	POWER=`sensors | grep power1 | awk -F: '{print $2}' | awk -F"W" '{print $1}'`
	GPUCLOCK=`cat /sys/class/hwmon/hwmon3/freq1_input`
	GPUCLOCK=`echo "$GPUCLOCK / 1000000" | bc`
	MEMCLOCK=`cat /sys/class/hwmon/hwmon3/freq2_input`
	MEMCLOCK=`echo "$MEMCLOCK / 1000000" | bc`
	MEMFREE=`glxinfo -B | grep "Currently available dedicated video memory:" | awk -F: '{print $2}' | awk -F"MB" '{print $1}'`
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
	sleep 2
done

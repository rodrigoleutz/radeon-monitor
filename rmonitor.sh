#!/bin/bash

# Script: Monitor de placa Radeon RX 580 no Arch Linux
# Autor: Rodrigo Leutz

trap ctrl_c INT

function ctrl_c() {
	setterm -cursor on
        echo "** Saiu do programa com ctrl+c"
	clear
	exit
}

VGA=`glxinfo -B | grep Device | awk -F"(" '{print $1}' | awk -F: '{print $2}'`
VGA=`echo $VGA | sed 's/ *$//g'`
MAXTEMP=`sensors | grep edge | awk -F+ '{ print $2 }' | awk -F° '{print $1}'`
MAXFAN=`sensors | grep fan1 | awk -F: '{print $2}' | awk -F"RPM" '{print $1}'`
MAXFAN=`echo $MAXFAN | sed 's/ *$//g'`
MAXPOWER=`sensors | grep power1 | awk -F: '{print $2}' | awk -F"W" '{print $1}'`
MAXPOWER=`echo $MAXPOWER | sed 's/ *$//g'`
MINTEMP=`sensors | grep edge | awk -F+ '{ print $2 }' | awk -F° '{print $1}'`
MINFAN=`sensors | grep fan1 | awk -F: '{print $2}' | awk -F"RPM" '{print $1}'`
MINFAN=`echo $MINFAN | sed 's/ *$//g'`
MINPOWER=`sensors | grep power1 | awk -F: '{print $2}' | awk -F"W" '{print $1}'`
MINPOWER=`echo $MINPOWER | sed 's/ *$//g'`
GPUCLOCK=`cat /sys/class/hwmon/hwmon3/freq1_input`
GPUCLOCKMIN=`cat /sys/class/hwmon/hwmon3/freq1_input`
GPUCLOCKMIN=`echo "$GPUCLOCKMIN / 1000000" | bc`
GPUCLOCKMAX=`cat /sys/class/hwmon/hwmon3/freq1_input`
GPUCLOCKMAX=`echo "$GPUCLOCKMAX / 1000000" | bc`
MEMCLOCK=`cat /sys/class/hwmon/hwmon3/freq2_input`
MEMCLOCKMIN=`cat /sys/class/hwmon/hwmon3/freq2_input`
MEMCLOCKMIN=`echo "$MEMCLOCK / 1000000" | bc`
MEMCLOCKMAX=`cat /sys/class/hwmon/hwmon3/freq2_input`
MEMCLOCKMAX=`echo "$MEMCLOCK / 1000000" | bc`
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
	clear
	POWER=`echo $POWER | sed 's/ *$//g'`
	FAN=`echo $FAN | sed 's/ *$//g'`
	if [ `echo "$TEMP < $MINTEMP"|bc` -eq 1 ]
        then
                 MINTEMP=$TEMP
        fi
	if [ `echo "$TEMP > $MAXTEMP"|bc` -eq 1 ]
        then
                 MAXTEMP=$TEMP
        fi
	if [ `echo "$FAN < $MINFAN"|bc` -eq 1 ]
        then
                 MINFAN=$FAN
        fi
        if [ `echo "$FAN > $MAXFAN"|bc` -eq 1 ]
        then
                 MAXFAN=$FAN
        fi
	if [ `echo "$POWER < $MINPOWER"|bc` -eq 1 ]
        then
                 MINPOWER=$POWER
        fi
        if [ `echo "$POWER > $MAXPOWER"|bc` -eq 1 ]
        then
                 MAXPOWER=$POWER
        fi
	if [ `echo "$GPUCLOCK < $GPUCLOCKMIN"|bc` -eq 1 ]
        then
                 GPUCLOCKMIN=$GPUCLOCK
        fi
        if [ `echo "$GPUCLOCK > $GPUCLOCKMAX"|bc` -eq 1 ]
        then
                 GPUCLOCKMAX=$GPUCLOCK
        fi
        if [ `echo "$MEMCLOCK < $MEMCLOCKMIN"|bc` -eq 1 ]
        then
                 MEMCLOCKMIN=$MEMCLOCK
        fi
        if [ `echo "$MEMCLOCK > $MEMCLOCKMAX"|bc` -eq 1 ]
        then
                 MEMCLOCKMAX=$MEMCLOCK
        fi
	if [ `echo "$MEMUSE < $MEMUSEMIN"|bc` -eq 1 ]
        then
                 MEMUSEMIN=$MEMUSE
        fi
        if [ `echo "$MEMUSE > $MEMUSEMAX"|bc` -eq 1 ]
        then
                 MEMUSEMAX=$MEMUSE
        fi
	dialog --colors --title "\Zb\Z1$VGA" \
	--infobox "\n\ZB\ZnGPU Clock     : \Z2$GPUCLOCK \ZnMHz
	\nGPU Clock Min : \Z4$GPUCLOCKMIN \ZnMHz
        \nGPU Clock Max : \Z3$GPUCLOCKMAX \ZnMHz
	\nMem Clock     : \Z2$MEMCLOCK \ZnmMHz
	\nMem Clock Min : \Z4$MEMCLOCKMIN \ZnMHz
        \nMem Clock Max : \Z3$MEMCLOCKMAX \ZnMHz
	\nMem Use       : \Z2$MEMUSE/$MEMTOTAL \ZnMB
	\nMem Use Min   : \Z4$MEMUSEMIN/$MEMTOTAL \ZnMB
        \nMem Use Max   : \Z3$MEMUSEMAX/$MEMTOTAL \ZnMB
	\nTemp          : \Z2$TEMP\Zn°C
	\nTemp Min      : \Z4$MINTEMP\Zn°C
        \nTemp Max      : \Z3$MAXTEMP\Zn°C
	\nFan           : \Z2$FAN \ZnRPM
	\nFan Min       : \Z4$MINFAN \ZnRPM
        \nFan Max       : \Z3$MAXFAN \ZnRPM
	\nPower         : \Z2$POWER \ZnW
	\nPower Min     : \Z4$MINPOWER \ZnW
        \nPower Max     : \Z3$MAXPOWER \ZnW\n
        \n(\Z1Ctrl+c\Zn para Sair)" 24 40
	setterm -cursor off
	sleep 2
done

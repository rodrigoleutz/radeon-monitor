#!/bin/bash

# Script: Monitor de placa Radeon RX 580 no Arch Linux
# Autor: Rodrigo Leutz

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
	echo $VGA
	echo
	echo -e "\e[97mGPU Clock : $GPUCLOCK \e[97mMHz"
	echo -e "\e[97mGPU Clock Min : \e[34m$GPUCLOCKMIN\e[97m MHz"
        echo -e "\e[97mGPU Clock Max : \e[93m$GPUCLOCKMAX\e[97m MHz"
	echo -e "\e[97mMem Clock : $MEMCLOCK \e[97mMHz"
	echo -e "\e[97mMem Clock Min : \e[34m$MEMCLOCKMIN\e[97m MHz"
        echo -e "\e[97mMem Clock Max : \e[93m$MEMCLOCKMAX\e[97m MHz"
	echo -e "\e[97mMem Use: \e[92m$MEMUSE\e[90m/\e[1m\e[95m$MEMTOTAL\e[97m MB"
	echo -e "\e[97mMem Use Min : \e[34m$MEMUSEMIN\e[97m MB"
        echo -e "\e[97mMem Use Max : \e[93m$MEMUSEMAX\e[97m MB"
	echo -e "\e[97mTemp    : $TEMP°C"
	echo -e "\e[97mTemp Min : \e[34m$MINTEMP\e[97m°C"
        echo -e "\e[97mTemp Max : \e[93m$MAXTEMP\e[97m°C"
	echo -e "\e[97mFan    : $FAN RPM"
	echo -e "\e[97mFan Min : \e[34m$MINFAN \e[97mRPM"
        echo -e "\e[97mFan Max: \e[93m$MAXFAN \e[97mRPM"
	echo -e "\e[97mPower    : $POWER W"
	echo -e "\e[97mPower Min : \e[34m$MINPOWER \e[97mW"
        echo -e "\e[97mPower Max : \e[93m$MAXPOWER \e[97mW"
	echo -e "\e[97m"
	sleep 2
done

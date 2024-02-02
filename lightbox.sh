#!/bin/bash

## Set Variables
shiftconfig="/home/kurona/.config/shift.txt"
lightconfig="/home/kurona/.config/lights.txt"
workDIR="/home/kurona/Public/sainsmart-16-channel-usb-relay-ch341"

# Set some Defaults to be overwritten
ARG0=${1:-auto}
PSUstate="off"
state="off"
MANual="auto"
BEDLamp="auto"

## Name relay zones
AzurLane="1"
Nyuunzi="2"
Taboolicious="3"
Standees="4"
Bedlamp="8"

# Overwrite Defaults with saved variables
source "$shiftconfig"
source "$lightconfig"

case "$ARG0" in
#________________________________
	setauto|reset)
#________________________________
	eval PSUstate="off"
	eval state="off"
	eval MANual="auto"
	printf "Auto-mode reenabled\nTrigger intervals are every n/5 minutes \n \n "
	;; # End of AUTO RESET option
#================================
#________________________________
	on|start)
#________________________________

	node "$workDIR"/16ch_usb.js 16 on
	eval state="on"
	eval PSUstate="on"
	eval MANual="on"
while [[ "$#" -gt "0" ]]; do
  case $1 in
	ny|nyuunzi) node "$workDIR"/16ch_usb.js "$Nyuunzi" on ;;
        al|azur|azurlane) node "$workDIR"/16ch_usb.js "$AzurLane" on ;;
        tb|taboo|taboolicious) node "$workDIR"/16ch_usb.js "$Taboolicious" on ;;
	sd|stands|standees) node "$workDIR"/16ch_usb.js "$Standees" on ;;
	bl|lamp|bed) node "$workDIR"/16ch_usb.js "$Bedlamp" on && eval BEDLamp="on" && eval MANual="auto" ;;
	*) node "$workDIR"/16ch_usb.js "$2" on ;;

  esac
	shift
done

	;; # End of ON option
#================================
#________________________________
	off|turnoff)
#________________________________
	eval state="on"
	eval PSUstate="on"
	eval MANual="on"
while [[ "$#" -gt "0" ]]; do
  case $1 in
        ny|nyuunzi) node "$workDIR"/16ch_usb.js "$Nyuunzi" off ;;
        al|azur|azurlane) node "$workDIR"/16ch_usb.js "$AzurLane" off ;;
        tb|taboo|taboolicious) node "$workDIR"/16ch_usb.js "$Taboolicious" off ;;
	sd|stands|standees) node "$workDIR"/16ch_usb.js "$Standees" off ;;
	bl|lamp|bed) node "$workDIR"/16ch_usb.js "$Bedlamp" off && eval BEDLamp="auto" && eval MANual="auto" ;;
	*) node "$workDIR"/16ch_usb.js "$2" off ;;
  esac
        shift
done
	;; # End of Shutoff option
#================================
#________________________________
	stop|shutoff)
#________________________________

        node "$workDIR"/16ch_usb.js reset
	eval state="off"
	eval PSUstate="off"
	eval MANual="off"
	eval BEDLamp="auto"

	;; # End of OFF option
#================================
#________________________________
	auto|*)
#________________________________
### Shift script interration
## Determine Day
# Off Days
  if [[ "$day" -lt "7" ]] && [[ $(date +%A) = "Sunday" ]]; then eval scheday="off" ;fi
  if [[ "$day" -lt "8" ]] && [[ $(date +%A) = "Wednesday" ]]; then eval scheday="off" ;fi
  if [[ "$day" -lt "9" ]] && [[ $(date +%A) = "Thursday" ]]; then eval scheday="off" ;fi
  if [[ "$day" -gt "7" ]] && [[ $(date +%A) = "Monday" ]]; then eval scheday="off" ;fi
  if [[ "$day" -gt "7" ]] && [[ $(date +%A) = "Tuesday" ]]; then eval scheday="off" ;fi
  if [[ "$day" -gt "7" ]] && [[ $(date +%A) = "Friday" ]]; then eval scheday="off" ;fi
  if [[ "$day" -gt "7" ]] && [[ $(date +%A) = "Saturday" ]]; then eval scheday="off" ;fi
# Work Days
  if [[ "$day" -lt "7" ]] && [[ $(date +%A) = "Monday" ]]; then eval scheday="work" ;fi
  if [[ "$day" -lt "7" ]] && [[ $(date +%A) = "Tuesday" ]]; then eval scheday="work" ;fi
  if [[ "$day" -lt "11" ]] && [[ $(date +%A) = "Friday" ]]; then eval scheday="work" ;fi
  if [[ "$day" -lt "11" ]] && [[ $(date +%A) = "Saturday" ]]; then eval scheday="work" ;fi
  if [[ "$day" -gt "7" ]] && [[ $(date +%A) = "Sunday" ]]; then eval scheday="work" ;fi
  if [[ "$day" -gt "7" ]] && [[ $(date +%A) = "Wednesday" ]]; then eval scheday="work" ;fi
  if [[ "$day" -gt "7" ]] && [[ $(date +%A) = "Thursday" ]]; then eval scheday="work" ;fi

## Bedside Lamp Control
# Control Ignores Kisaragi's state and Automation state
# Daytime Workdays
 if [[ "$wkshift" = "days" ]] && [[ "$scheday" = "work" ]]; then
   if [[ "$clock" -ge "4" && "$clock" -le "7" ]]; then
     if [[ "$PSUstate" = "off" ]]; then
	node "$workDIR"/16ch_usb.js 16 on && eval PSUstate="on"
     fi
	node "$workDIR"/16ch_usb.js "$Bedlamp" on
   elif [[ "$BEDLamp" = "auto" ]]; then
	node "$workDIR"/16ch_usb.js "$Bedlamp" off
   fi
 fi
# Night Work
 if [[ "$wkshift" = "nights" ]] && [[ "$scheday" = "work" ]]; then
   if [[ "$clock" -ge "16" && "$clock" -le "19" ]]; then
     if [[ "$PSUstate" = "off" ]]; then
	node "$workDIR"/16ch_usb.js 16 on && eval PSUstate="on"
     fi
	node "$workDIR"/16ch_usb.js "$Bedlamp" on
   elif [[ "$BEDLamp" = "auto" ]]; then
	node "$workDIR"/16ch_usb.js "$Bedlamp" off
   fi
 fi

## Accessory Lights
# Check if automode is enabled
		if [[ "$MANual" = "auto" ]]; then
## Basic State and Power
if [[ "$(curl -s --connect-timeout 2 10.0.0.47)" = "system awake" ]]; then
	eval state="on"
  else
	eval state="off"
fi
if [[ "$state" = "on" ]] && [[ "$PSUstate" = "off" ]]; then
	node "$workDIR"/16ch_usb.js 16 on && eval PSUstate="on"
  elif [[ "$state" = "off" ]] && [[ "$PSUstate" = "on" ]]; then
	node "$workDIR"/16ch_usb.js reset && eval PSUstate="off"
fi

## Schedule Automation
if [[ "$state" = "on" ]] && [[ "$PSUstate" = "on" ]]; then
# Define Time *Once* for triggers
	eval clock="$(date +%-H)"
# Daytime Workdays
  if [[ "$wkshift" = "days" ]] && [[ "$scheday" = "work" ]]; then
	# Nyuunzi & Standees
	if [[ "$clock" -ge "20" || "$clock" -le "7" ]]; then
	  node "$workDIR"/16ch_usb.js "$Nyuunzi" on
	  node "$workDIR"/16ch_usb.js "$Standees" on
	else
	  node "$workDIR"/16ch_usb.js "$Nyuunzi" off
	  node "$workDIR"/16ch_usb.js "$Standees" off
	fi
	# Azur Lane & Taboolicious
	if [[ "$clock" -ge "20" && "$clock" -lt "22" ]] || [[ "$clock" -ge "4" && "$clock" -lt "7" ]]; then
	   node "$workDIR"/16ch_usb.js "$AzurLane" on && node "$workDIR"/16ch_usb.js "$Taboolicious" on
	   else
 	   node "$workDIR"/16ch_usb.js "$AzurLane" off && node "$workDIR"/16ch_usb.js "$Taboolicious" off
	fi
  fi
# Daytime Offdays
  if [[ "$wkshift" = "days" ]] && [[ "$scheday" = "off" ]]; then
	# Nyuunzi
	if [[ "$clock" -ge "4" ]]; then
	  node "$workDIR"/16ch_usb.js "$Nyuunzi" on
	fi
	# Standees
	if [[ "$clock" -lt "7" ]] || [[ "$clock" -ge "20" ]]; then
	   node "$workDIR"/16ch_usb.js "$Standees" on 
	   else
	   node "$workDIR"/16ch_usb.js "$Standees" off
	fi
	# Azur Lane & Taboolicious
	if [[ "$clock" -ge "20" && "$clock" -lt "22" ]] || [[ "$clock" -ge "6" && "$clock" -lt "10" ]]; then
	   node "$workDIR"/16ch_usb.js "$AzurLane" on && node "$workDIR"/16ch_usb.js "$Taboolicious" on
	   else
 	   node "$workDIR"/16ch_usb.js "$AzurLane" off && node "$workDIR"/16ch_usb.js "$Taboolicious" off
	fi
  fi
# Night Offdays
  if [[ "$wkshift" = "nights" ]] && [[ "$scheday" = "off" ]]; then
	#Nyuunzi
	if [[ "$clock" -ge "0" ]]; then
	  node "$workDIR"/16ch_usb.js "$Nyuunzi" on
	fi
	# Standees
	if [[ "$clock" -ge "20" ]] || [[ "$clock" -lt "8" ]]; then
	   node "$workDIR"/16ch_usb.js "$Standees" on
	   else
	   node "$workDIR"/16ch_usb.js "$Standees" off
	fi
	# Azur Lane & Taboolicious
	if [[ "$clock" -ge "20" ]] || [[ "$clock" -lt "8" ]]; then
	   node "$workDIR"/16ch_usb.js "$AzurLane" on && node "$workDIR"/16ch_usb.js "$Taboolicious" on
	   else
 	   node "$workDIR"/16ch_usb.js "$AzurLane" off && node "$workDIR"/16ch_usb.js "$Taboolicious" off
	fi
  fi
# Night Work
  if [[ "$wkshift" = "nights" ]] && [[ "$scheday" = "work" ]]; then
	#Nyuunzi
	if [[ "$clock" -ge "0" ]]; then
	  node "$workDIR"/16ch_usb.js "$Nyuunzi" on
	fi
	# Standees
	if [[ "$clock" -ge "20" ]] || [[ "$clock" -lt "8" ]]; then
	   node "$workDIR"/16ch_usb.js "$Standees" on
	   else
	   node "$workDIR"/16ch_usb.js "$Standees" off
	fi
	# Azur Lane & Taboolicious
	if [[ "$clock" -ge "20" ]] || [[ "$clock" -lt "8" ]]; then
	   node "$workDIR"/16ch_usb.js "$AzurLane" on && node "$workDIR"/16ch_usb.js "$Taboolicious" on
	   else
	   node "$workDIR"/16ch_usb.js "$AzurLane" off && node "$workDIR"/16ch_usb.js "$Taboolicious" off
	fi

  fi
fi
		fi
#================================
	;; # End of AUTO option
#================================

esac

## Save config
echo "state=\"$state\"" > "$lightconfig"
echo "PSUstate=\"$PSUstate\"" >> "$lightconfig"
echo "MANual=\"$MANual\"" >> "$lightconfig"
echo "BEDLamp=\"$BEDLamp\"" >> "$lightconfig"
if [[ "$MANual" != "auto" ]]; then
  cat "$lightconfig"
fi

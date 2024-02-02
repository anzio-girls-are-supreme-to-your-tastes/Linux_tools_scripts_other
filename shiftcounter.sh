#!/bin/bash
config="/home/kurona/.config/shift.txt"

source "$config"


####
# Check date and flip schedule if second Saturday
if [[ "$day" -gt "9" ]] && [[ $(date +%A) = "Saturday" ]]; then
day="0"
        if [[ "$wkshift" = "days" ]]; then
wkshift="nights"
  sudo /usr/bin/crontab -u kurona /home/kurona/.config/cron/night
        elif [[ "$wkshift" = "nights" ]]; then
wkshift="days"
  sudo /usr/bin/crontab -u kurona /home/kurona/.config/cron/day

        fi

fi
####
# Add a day to counter
(( day++ ))

####
# Save config
echo "day=\"$day\"" > "$config"
echo "wkshift=\"$wkshift\"" >> "$config"

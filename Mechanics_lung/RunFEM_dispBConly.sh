#!/bin/bash

#declare -a StringVal=("a03" "a04" "a05" "a06" "a07" "y01" "y02" "y03" "s04" "s05" "s06")
declare -a StringVal=("a03" "a04")

monit="monit"

# Iterate the string variable using for loop
for val in ${StringVal[@]}; do

#perl RunASubject.pl UCSD $val Right Supine Supine > $val$monit 
 perl RunASubject.pl UCSD $val Right Supine Supine 

 ## Bash add pause prompt for 60 seconds ##
 read -t 60 -p "I am going to wait for 60 seconds only ..."

done

#
#perl RunASubject.pl UCSD a03 Right Supine Supine > a3monit &
### Bash add pause prompt for 15 seconds ##
#read -t 15 -p "I am going to wait for 15 seconds only ..."
#
#perl RunASubject.pl UCSD a04 Right Supine Supine > a4monit &
### Bash add pause prompt for 15 seconds ##
#read -t 15 -p "I am going to wait for 15 seconds only ..."
#
#perl RunASubject.pl UCSD a05 Right Supine Supine > a5monit &
### Bash add pause prompt for 15 seconds ##
#read -t 15 -p "I am going to wait for 15 seconds only ..."
#
#perl RunASubject.pl UCSD a06 Right Supine Supine > a6monit &
### Bash add pause prompt for 15 seconds ##
#read -t 15 -p "I am going to wait for 15 seconds only ..."
#
#perl RunASubject.pl UCSD a07 Right Supine Supine > a7monit &
### Bash add pause prompt for 15 seconds ##
#read -t 15 -p "I am going to wait for 15 seconds only ..."
#
#perl RunASubject.pl UCSD y01 Right Supine Supine > y1monit &
### Bash add pause prompt for 15 seconds ##
#read -t 15 -p "I am going to wait for 15 seconds only ..."
#
#perl RunASubject.pl UCSD y02 Right Supine Supine > y2monit &
#perl RunASubject.pl UCSD y03 Right Supine Supine > y3monit &
#
#perl RunASubject.pl UCSD s04 Right Supine Supine > s4monit &
#perl RunASubject.pl UCSD s05 Right Supine Supine > s5monit &
#perl RunASubject.pl UCSD s06 Right Supine Supine > s6monit &
#
#

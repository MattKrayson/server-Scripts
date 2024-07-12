#!/bin/bash

while true; do
    # Get CPU frequencies
    cpu_frequencies=$(grep MHz /proc/cpuinfo | awk '{print $4}')

    # Get CPU temperatures
    cpu_temperatures=$(sensors | grep 'Core' | awk '{print $3}')

    # Get network activity (adjust 'eth0' to your network interface)
    network_activity=$(ifstat -i enp3s0 0.1 1 | awk 'NR==3 {print $1, $2}')

    # Clear the screen before printing updated content
    clear

    # Print headers for readability
    echo -e "CPU MHz   |   Temp   |   RX |  TX"
    echo -e "----------|----------|-------------"

    # Combine the output and format as a table
    paste <(echo "$cpu_frequencies") <(echo "$cpu_temperatures") <(echo "$network_activity") | awk -F'\t' '{printf "%-8s  | %-7s  | %-5s  %-5s \n"  , $1, $2, $3, $4}'

    # Sleep for 0.5 seconds
    sleep 0.5
done


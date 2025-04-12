#!/bin/sh

RAMP0="%{F#99d0e5} %{F-}" 
RAMP1="%{F#86d3d2} %{F-}"
RAMP2="%{F#74fcbf} %{F-}"
RAMP3="%{F#9ae49a} %{F-}"
RAMP4="%{F#e4c07a} %{F-}"
RAMP5="%{F#e4a470} %{F-}"
RAMP6="%{F#e88761} %{F-}"
RAMP7="%{F#e87461} %{F-}"
RAMP8="%{F#e86161} %{F-}"
RAMP9="%{F#e86161} %{F-}"

# Number of top cores to consider for the average
TOP_CORES_COUNT=7

# Function to calculate the average of the top N hottest cores
calculate_average_top_cores() {
    # Sort the temperatures in descending order and pick the top N
    top_temps=$(printf "%s\n" "$@" | sort -nr | head -n $TOP_CORES_COUNT)
    sum=0
    count=0
    # Calculate the sum of the top N temperatures
    for temp in $top_temps; do
        sum=$((sum + temp))
        ((count++))
    done

    if [ $count == 0 ]; then
        echo "Sensors not found"
    fi

    # Calculate the average
    average=$((sum / count))

    if [ $average -lt 35 ]; then
        ramp=$RAMP0
    elif [ $average -lt 38 ]; then
        ramp=$RAMP1
    elif [ $average -lt 41 ]; then
        ramp=$RAMP2
    elif [ $average -lt 44 ]; then
        ramp=$RAMP3
    elif [ $average -lt 47 ]; then
        ramp=$RAMP4
    elif [ $average -lt 60 ]; then
        ramp=$RAMP5
    elif [ $average -lt 70 ]; then
        ramp=$RAMP6
    elif [ $average -lt 80 ]; then
        ramp=$RAMP7
    elif [ $average -lt 90 ]; then
        ramp=$RAMP8
    else
        ramp=$RAMP9
    fi

    echo "$ramp$average°C"
}

INPUT=$(sensors | grep Core | awk '{print substr($3, 2, length($3)-5)}')
calculate_average_top_cores $INPUT

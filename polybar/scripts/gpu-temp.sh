#!/bin/sh

RAMP0="%{F#99d0e5} %{F-}"  # Blue - Cool
RAMP1="%{F#e4c07a} %{F-}"  # Orange - Warm, idle
RAMP2="%{F#e4a470} %{F-}"  # Orange - Slightly warmer
RAMP3="%{F#e88761} %{F-}"  # Orange - Warm
RAMP4="%{F#e87461} %{F-}"  # Reddish - Hot
RAMP5="%{F#e86161} %{F-}"  # Red - Hotter
RAMP6="%{F#e86161} %{F-}"  # Red - Maximum

# Function to determine the ramp based on the GPU temperature
get_gpu_temp_ramp() {
    gpu_temp=$1

    if [ $gpu_temp -lt 40 ]; then
        ramp=$RAMP0
    elif [ $gpu_temp -lt 45 ]; then
        ramp=$RAMP1
    elif [ $gpu_temp -lt 50 ]; then
        ramp=$RAMP2
    elif [ $gpu_temp -lt 55 ]; then
        ramp=$RAMP3
    elif [ $gpu_temp -lt 65 ]; then
        ramp=$RAMP4
    elif [ $gpu_temp -lt 75 ]; then
        ramp=$RAMP5
    else
        ramp=$RAMP6
    fi

    echo "$ramp$gpu_temp°C"
}

# Get the GPU temperature using nvidia-smi
GPU_TEMP=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits)

# Call the function to determine the ramp and display the temperature
get_gpu_temp_ramp $GPU_TEMP

#!/bin/bash

green='\033[0;32m'
red='\033[0;31m'
reset='\033[0m'

while true; do
    echo -e "${green}\nDrag video here and press 'Enter ↵':${reset}"
    read video_dir
    if [ -f "$video_dir" ]; then
        break
    else
        echo -e "${red}File does not exist. Please enter a valid video directory.${reset}"
    fi
done

parent_dir=$(dirname "$video_dir")
filename=$(basename -- "$video_dir")
filename_no_ext="${filename%.*}"
image_folder="${parent_dir}/${filename_no_ext}_image_sequence"

mkdir -p "$image_folder"

info=$(ffprobe -v error -select_streams v:0 -show_entries stream=height,width,r_frame_rate -of csv=p=0 "$video_dir")
height=$(echo $info | awk -F, '{print $1}')
width=$(echo $info | awk -F, '{print $2}')
fps_fraction=$(echo $info | awk -F, '{print $3}')
fps=$(echo "$fps_fraction" | bc -l)

ffmpeg -i "$video_dir" -vf "fps=$fps" -q:v 2 "${image_folder}/is_%06d.jpg"

while true; do
    echo -e "${green}\nManually remove background using Quick Actions > Remove Background.\nThen, enter the postfix for created files [Press 'Enter ↵' for default 'Background Removed']:${reset}"
    read postfix

    if [ -z "$postfix" ]; then
        postfix="Background Removed"
    fi

    if [ -f "${image_folder}/is_000001 ${postfix}.png" ]; then
        break
    else
        echo -e "${red}No background-removed images found. Make sure to remove the background for all images and try again.${reset}"
    fi
done

echo -e "${green}\nEnter the background color (e.g., blue, yellow, #FF0000, #000000 etc.) [Press 'Enter ↵' for default white]:${reset}"
read bg_color
if [ -z "$bg_color" ]; then
    bg_color='white'
fi

output_filename="${parent_dir}/${filename_no_ext} ${postfix}.mp4"
ffmpeg -framerate $fps -i "${image_folder}/is_%06d ${postfix}.png" -f lavfi -i "color=c=${bg_color}:s=${width}x${height}:r=$fps" -filter_complex "[1:v][0:v]overlay=shortest=1" -r $fps "$output_filename"

echo -e "${green}\nDo you want to delete the generated images and their folder? (y/N)${reset}"
read delete_option

if [[ $delete_option == "Y" || $delete_option == "y" ]]; then
    rm -rf "$image_folder"
fi

echo -e "${green}\nDone!${reset}"

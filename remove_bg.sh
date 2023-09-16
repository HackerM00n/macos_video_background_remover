#!/bin/bash

green='\033[0;32m'
red='\033[0;31m'
orange='\033[0;33m'
reset='\033[0m'

video_dir="$1"
if [ ! -f "$video_dir" ]; then
    echo -e "${red}File does not exist. Please enter a valid video directory.${reset}"
    exit 1
fi

bg_color="$2"
if [ -z "$bg_color" ]; then
    bg_color='#FFFFFF'
fi

echo -e "${green}Video path:${reset} $video_dir"

echo -e "${green}Background color:${reset} $bg_color"

if ! command -v brew &> /dev/null; then
  echo -e "${orange}Homebrew is not installed, installing now...${reset}"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if ! command -v ffmpeg &> /dev/null; then
  echo -e "${orange}FFmpeg is not installed, installing now...${reset}"
  brew install ffmpeg
fi

if ! command -v identify &> /dev/null; then
  echo -e "${orange}ImageMagick is not installed, installing now...${reset}"
  brew install imagemagick
fi

parent_dir=$(dirname "$video_dir")
filename=$(basename -- "$video_dir")
filename_no_ext="${filename%.*}"
image_folder="${parent_dir}/${filename_no_ext}_image_sequence"

mkdir -p "$image_folder"

fps=$(ffprobe -v error -select_streams v:0 -show_entries stream=r_frame_rate -of default=noprint_wrappers=1:nokey=1 "$video_dir" | bc -l)

ffmpeg -i "$video_dir" -vf "fps=$fps" -q:v 2 "${image_folder}/is_%06d.jpg"

dimensions=$(identify -format "%wx%h" "${image_folder}/is_000001.jpg")
width=$(echo $dimensions | awk -Fx '{print $1}')
height=$(echo $dimensions | awk -Fx '{print $2}')

open "$image_folder"

while true; do
    echo -e "${green}Select .jpg files in the created '<video_name>_image_sequence' folder, and perform Quick Actions > Remove Background.\nThen, enter the postfix for created files [Press 'Enter ↵' for default 'Background Removed']:${reset}"
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

output_filename="${parent_dir}/${filename_no_ext} ${postfix}.mp4"
ffmpeg -framerate $fps -i "${image_folder}/is_%06d ${postfix}.png" -f lavfi -i "color=c=${bg_color}:s=${width}x${height}:r=$fps" -filter_complex "[1:v][0:v]overlay=shortest=1" -r $fps "$output_filename"

echo -e "${green}Do you want to delete the generated images and their folder? (y/N)${reset}"
read delete_option

if [[ $delete_option == "Y" || $delete_option == "y" ]]; then
    rm -rf "$image_folder"
fi

echo -e "${green}Done!${reset}"

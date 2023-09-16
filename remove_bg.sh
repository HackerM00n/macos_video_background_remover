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
    echo -e "${green}Select .jpg files in the created '<video_name>_image_sequence' folder, and perform Quick Actions > Remove Background.\nOnce done, press 'Enter ↵' to continue.${reset}"
    read -r dummy

    if ls "${image_folder}"/*.png 1> /dev/null 2>&1; then
        break
    else
        echo -e "${red}No background-removed images found. Make sure to remove the background for all images and try again.${reset}"
    fi
done

first_png=$(ls "${image_folder}"/is_*.png | sort -V | head -n 1)
postfix=$(basename "$first_png" | sed -E 's/is_[0-9]+ //;s/\.png//')

min_index=1
max_index=$(ls "${image_folder}"/is_*.png | sed -E 's/.*\/is_([0-9]+).*/\1/' | sort -n | tail -n1)

for i in $(seq -f "%06g" $min_index $max_index); do
    png_file="${image_folder}/is_${i} ${postfix}.png"
    if [ ! -f "$png_file" ]; then
        convert -size ${width}x${height} "xc:${bg_color}" "$png_file"
    fi
done

output_filename="${parent_dir}/${filename_no_ext} ${postfix}.mp4"
ffmpeg -framerate $fps -i "${image_folder}/is_%06d ${postfix}.png" -f lavfi -i "color=c=${bg_color}:s=${width}x${height}:r=$fps" -filter_complex "[1:v][0:v]overlay=shortest=1" -r $fps "$output_filename"

has_audio=$(ffprobe -show_streams "$video_dir" 2>&1 | grep -c "Stream #[0-9]*:.*Audio:")

if [ "$has_audio" -gt 0 ]; then
    if [ $? -eq 0 ]; then
        echo -e "${green}Do you want to copy the audio from the original video? (y/N)${reset}"
        read copy_audio_option

        if [[ $copy_audio_option == "Y" || $copy_audio_option == "y" ]]; then
            audio_file="${parent_dir}/${filename_no_ext}_audio.aac"
            ffmpeg -i "$video_dir" -vn -acodec copy "$audio_file"

            final_output="${parent_dir}/${filename_no_ext} ${postfix} With Audio.mp4"
            ffmpeg -i "$output_filename" -i "$audio_file" -c:v copy -c:a aac -strict experimental "$final_output"
            if [ $? -eq 0 ]; then
                echo -e "${green}Audio copied successfully.${reset}"
                rm -f "$audio_file"
            else
                echo -e "${red}Error copying audio.${reset}"
            fi
        else
            echo -e "${orange}No audio copied.${reset}"
        fi
    else
        echo -e "${red}Error extracting audio.${reset}"
    fi
else
    echo -e "${orange}The original video doesn't have an audio stream.${reset}"
fi

echo -e "${green}Do you want to delete the generated images and their folder? (y/N)${reset}"
read delete_option

if [[ $delete_option == "Y" || $delete_option == "y" ]]; then
    rm -rf "$image_folder"
    rm -f "$audio_file"
fi

echo -e "${green}Done!${reset}"

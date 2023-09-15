# Remove Background from Video Using Native macOS Feature and FFmpeg

## Overview

This script automates the process of background removal from a video using FFmpeg and macOS's built-in "Quick Actions > Remove Background" feature. It converts your video into a sequence of images, allows you to manually remove the background, and then compiles the images back into a video with an optional custom background color.

## How to Run the Script

1. **Make the Script Executable**: Navigate to the directory where you saved `remove_bg.sh` and run the following command to make the script executable:

    ```bash
    chmod +x remove_bg.sh
    ```

2. **Run the Script**: Execute the script by running `./remove_bg.sh` in the terminal.

3. **Follow the Prompts**: The script will ask you to provide various information like the video directory, postfix for background-removed images, and optional custom background color.

4. **Manually Remove Background**: When prompted, open the created `<video_name>_image_sequence` folder, select all files, and manually execute macOS's "Quick Actions > Remove Background" feature on them.

5. **Finish**: After confirming that all backgrounds have been removed successfully, the script will compile the images back into a video.

> **Note**: Make sure you have FFmpeg and ffprobe installed and available in your PATH for the script to work. If they are not already installed, you can install them via Homebrew using the command `brew install ffmpeg`.

## Enjoy your background-free video!
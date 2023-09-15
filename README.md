# Remove Background from Video - macOS Quick Action

## Overview

This script automates the process of background removal from a video using FFmpeg and macOS's built-in "Quick Actions > Remove Background" feature. It converts your video into a sequence of images, allows you to manually remove the background, and then compiles the images back into a video with an optional custom background color.

## Prerequisites

- [Homebrew](https://brew.sh/) (will be installed automatically if not present)
- FFmpeg and ImageMagick (will be installed automatically if not present)

## Installation

1. **Download the Workflow and Script**: Download the `.workflow` file and `remove_bg.sh` script.

2. **Install the Workflow**: Double-click the `.workflow` file to install it. This will add it to your Quick Actions list.

3. **Move the Script**: Move the `remove_bg.sh` script to your root user folder (`~/`).

4. **Make the Script Executable**: Open Terminal and run the following command to make the script executable:
    ```bash
    chmod +x ~/remove_bg.sh
    ```

### macOS Cannot Verify That This App is Free From Malware

If you encounter the "macOS Cannot Verify That This App is Free From Malware" error, you can resolve it by doing the following:

- Go to `System Preferences > Security & Privacy > General`.
- Under the 'Allow apps downloaded from:' section, you should see a message about the script being blocked. Click 'Open Anyway' to proceed.

## How to Run the Script Using Quick Actions

1. **Select the Video**: Right-click on the video file and select "Quick Actions > Remove Background from Video".

2. **Follow the Prompts**: The Terminal will automatically open, and you'll be prompted to:
    - **Manually Remove Backgrounds from a Sequence of Images**: The folder containing the image sequence will automatically open. Select all images and use "Quick Actions > Remove Background".
    - **Wait for PNG Files**: Please wait until the .png files appear before proceeding.
    - **Enter the Postfix**: You will be asked to enter the postfix used in the PNG filenames (e.g., "Background Removed"). This may vary depending on your macOS language setting.
    - **Set a Custom Background Color**: You can choose a custom background color instead of the default 'white'.
    - **Delete Images**: After the script has successfully created the video, you'll have the option to delete the generated image sequence if you want.


## Enjoy Your Background-Free Video!

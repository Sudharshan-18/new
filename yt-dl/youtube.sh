#!/bin/bash

# Prompt user for YouTube URL
echo "Enter the YouTube URL: "
read youtube_url

# Define download location
download_dir="/home/sudharshan/Downloads"
yt_dl_dir="/home/sudharshan/var/www/pg-st33/yt-dl"
current_date=$(date +%Y-%m-%d)
target_directory="$yt_dl_dir/$current_date"

# Ensure yt-dlp is installed
if ! command -v yt-dlp &> /dev/null; then
    echo "yt-dlp could not be found, installing..."
    sudo apt update
    sudo apt install -y yt-dlp
fi

# Download video in mp4 format, avoid downloading playlist
if ! yt-dlp --no-playlist -f mp4 -o "$download_dir/%(title)s.%(ext)s" "$youtube_url"; then
    echo "Failed to download video."
    exit 1
fi

# Find the downloaded video (assume the most recent mp4 file)
video_path=$(ls -t "$download_dir"/*.mp4 2>/dev/null | head -n 1)
if [ -z "$video_path" ]; then
    echo "No .mp4 file found in $download_dir. Download may have failed."
    exit 1
fi

video_name=$(basename "$video_path")

# Create directory for current date if it doesn't exist, with sudo for permissions
if [ ! -d "$target_directory" ]; then
    sudo mkdir -p "$target_directory"
fi

# Move the downloaded video to the target directory
sudo mv "$video_path" "$target_directory/$video_name"

# Check if move was successful
if [ ! -f "$target_directory/$video_name" ]; then
    echo "Failed to move video to $target_directory."
    exit 1
fi

# Extract video details
video_title=$(yt-dlp --get-title "$youtube_url")
video_size=$(du -h "$target_directory/$video_name" | cut -f1)
download_date=$(date '+%Y-%m-%d %H:%M:%S')
file_location="$target_directory/$video_name"

# Log details in list.txt, with sudo for permissions
log_file="$yt_dl_dir/list.txt"
{
  echo "Title: $video_title"
  echo "File Name: $video_name"
  echo "Size: $video_size"
  echo "Download Date: $download_date"
  echo "File Location: $file_location"
  echo "--------------------------------------------"
} | sudo tee -a "$log_file" >/dev/null

# Inform the user
echo "Video downloaded and moved to $target_directory"

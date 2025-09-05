#!/bin/bash

# Show folder selection dialog
echo "Please select the directory where you want to save the file..."
# Bring Terminal to front and then show folder selection dialog
osascript -e 'tell application "Terminal" to activate'
save_dir=$(osascript -e 'tell application "Finder" to return POSIX path of (choose folder with prompt "Select directory to save the translator app")')

# Check if user cancelled the dialog
if [ -z "$save_dir" ]; then
    echo "Installation cancelled by user."
    exit 0
fi

# Remove trailing slash if present
save_dir=${save_dir%/}

echo "Selected directory: $save_dir"

# Check if the directory exists, if not create it
if [ ! -d "$save_dir" ]; then
    mkdir -p "$save_dir"
fi

# Change to the specified directory
cd "$save_dir" || exit 1

# Download the zip file
zip_url="https://github.com/herryvn/superkeyboard/raw/refs/heads/main/dist/app.zip"
echo "Downloading app.zip from: $zip_url"
curl -L -v -o app.zip "$zip_url"

# Check if the download was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to download the file."
    exit 1
fi

# Check file size
file_size=$(stat -f%z app.zip 2>/dev/null || stat -c%s app.zip 2>/dev/null)
echo "Downloaded file size: $file_size bytes"

if [ "$file_size" -eq 0 ]; then
    echo "Error: Downloaded file is empty (0 bytes)."
    echo "This usually means the URL is incorrect or the file doesn't exist."
    echo "Please check the URL: $zip_url"
    exit 1
fi

# Unzip the downloaded file
echo "Unzipping app.zip..."
unzip -o app.zip

# Check if unzip was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to unzip the file."
    exit 1
fi

# Set execute permissions for the translator.app
app_path="dist/translator.app"
if [ -d "$app_path" ]; then
    echo "Setting execute permissions for translator.app..."
    chmod -R +x "$app_path/Contents/MacOS/"*
else
    echo "Error: translator.app not found in dist directory."
    exit 1
fi

# Open the translator.app
echo "Opening translator.app..."
open "$app_path"

# Check if the app opened successfully
if [ $? -ne 0 ]; then
    echo "Error: Failed to open translator.app."
    exit 1
fi

# Open the folder containing translator.app
echo "Opening folder containing translator.app..."
open "$(dirname "$app_path")"

echo "Installation and setup complete!"
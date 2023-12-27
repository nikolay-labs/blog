#!/bin/bash

# Directory containing Markdown files
SOURCE_DIR="./md"

# Directory where the HTML files will be saved
DEST_DIR="./html"

# Create the destination directory if it doesn't exist
mkdir -p "$DEST_DIR"

# Loop through all markdown files in the SOURCE_DIR and convert them to HTML in the DEST_DIR
for mdfile in "$SOURCE_DIR"/*.md; do
    # Get the filename without the extension
    filename=$(basename -- "$mdfile")
    filename="${filename%.*}"

    # Convert the file to HTML and save it in DEST_DIR
    pandoc "$mdfile" -o "$DEST_DIR/$filename.html"
done

echo "Markdown to HTML conversion complete."


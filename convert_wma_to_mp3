#!/bin/bash

# convert_wma_to_mp3.sh
# Converts all WMA files to MP3 format in a specified directory
# CONFIGURE THIS PATH:
MUSIC_FOLDER="/path/to/your/music/folder"  # ← Change this to your music folder path

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Validate input folder exists
if [[ ! -d "$MUSIC_FOLDER" ]]; then
    echo -e "${RED}Error: Music folder does not exist: $MUSIC_FOLDER${NC}"
    exit 1
fi

echo -e "${YELLOW}Starting WMA to MP3 conversion...${NC}"
echo "Music folder: $MUSIC_FOLDER"
echo ""

# Counter for statistics
files_converted=0
files_failed=0
files_skipped=0

# Convert all .wma files to .mp3
for file in "$MUSIC_FOLDER"/**/*.wma; do
    # Check if the glob pattern matched anything
    if [[ ! -e "$file" ]]; then
        echo -e "${YELLOW}No WMA files found.${NC}"
        break
    fi
    
    # Get directory and filename
    dir=$(dirname "$file")
    filename=$(basename "$file" .wma)
    output_file="$dir/$filename.mp3"
    
    # Skip if MP3 already exists
    if [[ -f "$output_file" ]]; then
        echo -e "${YELLOW}⊘ Already exists (skipping): $filename.mp3${NC}"
        ((files_skipped++))
        continue
    fi
    
    # Convert using ffmpeg
    echo -e "${YELLOW}Converting: $filename.wma${NC}"
    if ffmpeg -i "$file" -q:a 0 "$output_file" < /dev/null 2>&1 | grep -v "frame="; then
        echo -e "${GREEN}✓ Converted: $filename.wma → $filename.mp3${NC}"
        ((files_converted++))
        
        # Remove original WMA file
        rm "$file"
    else
        echo -e "${RED}✗ Failed: $filename.wma${NC}"
        ((files_failed++))
    fi
done

echo ""
echo -e "${YELLOW}Summary:${NC}"
echo "Files converted: $files_converted"
echo "Files skipped: $files_skipped"
if [[ $files_failed -gt 0 ]]; then
    echo -e "${RED}Files failed: $files_failed${NC}"
fi

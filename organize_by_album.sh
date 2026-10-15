#!/bin/bash

# organize_by_album.sh
# Groups music files into album folders based on metadata
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

echo -e "${YELLOW}Organizing music files by album...${NC}"
echo "Music folder: $MUSIC_FOLDER"
echo ""

# Counter for statistics
albums_created=0
files_moved=0
files_skipped=0

# Process all music files
for music_file in "$MUSIC_FOLDER"/*.{mp3,flac,ogg,m4a}; do
    # Check if the glob pattern matched anything
    if [[ ! -e "$music_file" ]]; then
        continue
    fi
    
    # Extract metadata using mid3v2
    filename=$(basename "$music_file")
    album=$(mid3v2 --list "$music_file" 2>/dev/null | grep "^TALB=" | cut -d'=' -f2- | head -1)
    
    # Fallback to "unknown_album" if metadata is missing
    if [[ -z "$album" ]]; then
        album="unknown_album"
    fi
    
    # Sanitize album name (remove/replace problematic characters)
    album_clean=$(echo "$album" | sed 's/[\/:\*?"<>|]/_/g' | xargs)
    
    # Create album folder if it doesn't exist
    album_folder="$MUSIC_FOLDER/$album_clean"
    if [[ ! -d "$album_folder" ]]; then
        mkdir -p "$album_folder"
        echo -e "${GREEN}✓ Created album folder: $album_clean${NC}"
        ((albums_created++))
    fi
    
    # Move file into album folder
    if [[ -f "$music_file" ]]; then
        mv "$music_file" "$album_folder/$filename"
        echo -e "${GREEN}✓ Moved: $filename → $album_clean/${NC}"
        ((files_moved++))
    fi
done

echo ""
echo -e "${YELLOW}Summary:${NC}"
echo "Albums created: $albums_created"
echo "Files moved: $files_moved"
echo ""
echo -e "${YELLOW}Manual next step:${NC}"
echo "Review '$MUSIC_FOLDER/unknown_album' folder"
echo "Move or rename albums as needed, then re-run this script if necessary"

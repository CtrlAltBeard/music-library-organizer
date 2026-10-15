#!/bin/bash

# group_by_artist.sh
# Groups album folders under artist directories using metadata
# CONFIGURE THIS PATH:
MUSIC_FOLDER="/path/to/your/music/folder"  # ← Change this to your music folder path

set -u

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

echo -e "${YELLOW}Grouping albums by artist...${NC}"
echo "Music folder: $MUSIC_FOLDER"
echo ""

# Counter for statistics
artists_created=0
albums_moved=0
errors=0

# Get list of all folders first (before any modifications)
mapfile -t folders < <(find "$MUSIC_FOLDER" -maxdepth 1 -mindepth 1 -type d ! -name "Artists" ! -name "Compilations" -print0 | xargs -0 -I {} basename {})

# Process each folder
for folder_name in "${folders[@]}"; do
    album_folder="$MUSIC_FOLDER/$folder_name"
    
    # Skip if folder no longer exists (might have been moved already)
    if [[ ! -d "$album_folder" ]]; then
        continue
    fi
    
    # Extract artist name from the first .mp3 file's metadata
    mp3_file=$(find "$album_folder" -maxdepth 1 -type f -name "*.mp3" | head -1)
    
    if [[ -z "$mp3_file" ]]; then
        echo -e "${YELLOW}⚠ Skipping '$folder_name' (no .mp3 files found)${NC}"
        continue
    fi
    
    # Extract artist and album names using mid3v2
    artist=$(mid3v2 --list "$mp3_file" 2>/dev/null | grep "^TPE1=" | cut -d'=' -f2- | head -1 || true)
    album=$(mid3v2 --list "$mp3_file" 2>/dev/null | grep "^TALB=" | cut -d'=' -f2- | head -1 || true)
    
    # Fallback to folder names if metadata is missing
    if [[ -z "$artist" ]]; then
        artist="Unknown Artist"
    fi
    
    if [[ -z "$album" ]]; then
        album="$folder_name"
    fi
    
    # Sanitize artist and album names (remove/replace problematic characters)
    artist_clean=$(echo "$artist" | sed 's/[\/:\*?"<>|]/_/g' | xargs)
    album_clean=$(echo "$album" | sed 's/[\/:\*?"<>|]/_/g' | xargs)
    
    # Create artist directory
    artist_dir="$MUSIC_FOLDER/Artists/$artist_clean"
    if [[ ! -d "$artist_dir" ]]; then
        mkdir -p "$artist_dir"
        echo -e "${GREEN}✓ Created artist folder: $artist_clean${NC}"
        ((artists_created++))
    fi
    
    # Move album folder to artist directory
    album_dest="$artist_dir/$album_clean"
    
    # Check if destination already exists
    if [[ -d "$album_dest" ]]; then
        echo -e "${RED}✗ Destination exists: $artist_clean/$album_clean (skipping)${NC}"
        ((errors++))
        continue
    fi
    
    # Move the album folder
    if mv "$album_folder" "$album_dest" 2>/dev/null; then
        echo -e "${GREEN}✓ Moved: $album_clean → $artist_clean/${NC}"
        ((albums_moved++))
    else
        echo -e "${RED}✗ Failed to move: $album_folder${NC}"
        ((errors++))
    fi
    
done

echo ""
echo -e "${YELLOW}Summary:${NC}"
echo "Artists created: $artists_created"
echo "Albums moved: $albums_moved"
if [[ $errors -gt 0 ]]; then
    echo -e "${RED}Errors encountered: $errors${NC}"
fi

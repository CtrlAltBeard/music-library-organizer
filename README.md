# Music Library Organizer

A collection of Bash scripts to organize a music library by artist and album, with automatic WMA-to-MP3 conversion.

## Features

- **WMA to MP3 conversion** — Batch converts WMA files to MP3 format using ffmpeg
- **Album organization** — Groups individual songs into album folders based on metadata
- **Artist grouping** — Organizes album folders under parent artist directories
- **Metadata-driven** — Uses ID3 tags from music files to determine structure
- **Fallback handling** — Handles missing metadata gracefully (unknown artists/albums)
- **Character sanitization** — Removes illegal filesystem characters from folder names
- **Efficient file movement** — Moves files rather than copying to save storage space

## Directory Structure

After running all scripts, your music library will be organized as:
Music/
├── Artists/
│   ├── Artist Name 1/
│   │   ├── Album Name 1/
│   │   │   ├── song1.mp3
│   │   │   ├── song2.mp3
│   │   │   └── ...
│   │   └── Album Name 2/
│   │       └── ...
│   ├── Artist Name 2/
│   │   └── Album Name/
│   │       └── ...
│   └── Unknown Artist/
│       ├── Album Name/
│       │   └── ...
│       └── Unknown Album/
│           └── ...
└── Compilations/
├── Compilation Album 1/
│   └── song.mp3
└── Compilation Album 2/
└── ...


## Prerequisites

Install required tools:

bash
sudo apt-get install ffmpeg mutagen
Usage

1. Convert WMA to MP3
bash

./convert\_wma\_to\_mp3.sh

What it does:
Finds all .wma files in the Music folder
Converts each to .mp3 using ffmpeg
Deletes the original .wma file
Displays progress for each conversion
Estimated time: Depends on file count and size (typically 1-5 minutes per GB)

2. Organize by Album
bash

./organize\_by\_album.sh

What it does:
Reads metadata (album name) from each MP3 file
Creates folders named after albums
Moves songs into their respective album folder
Falls back to unknown_album if metadata is missing

Folder structure after:

Music/
├── Album Name 1/
│   ├── song1.mp3
│   └── song2.mp3
├── Album Name 2/
│   └── song3.mp3
└── unknown\_album/
    └── song\_without\_metadata.mp3
3. Manually Handle Compilations (Optional)
Before running the artist grouping script, move compilation albums to the Compilations folder:

bash

mkdir -p Music/Compilations
mv "Music/Compilation Album Name" "Music/Compilations/"

Repeat for each compilation album.

4. Group by Artist

bash

./group\_by\_artist.sh

What it does:
Reads metadata (artist name) from each album folder
Creates parent folders for each artist
Moves album folders under their artist directory
Sanitizes illegal filesystem characters
Skips Artists and Compilations folders

Folder structure after:

Music/
├── Artists/
│   ├── Artist Name/
│   │   ├── Album 1/
│   │   │   └── songs...
│   │   └── Album 2/
│   │       └── songs...
│   └── Unknown Artist/
│       └── albums...
└── Compilations/
    └── compilation albums...

Script Details
convert_wma_to_mp3.sh
Input: Music folder with .wma files
Output: .mp3 files (originals deleted)

Key features:
Uses ffmpeg for conversion
Preserves ID3 metadata during conversion
Uses < /dev/null to prevent interactive prompts
Shows conversion progress

Configuration:
Edit the MUSIC_FOLDER variable at the top to point to your music directory.

organize_by_album.sh
Input: Music folder with flat song files
Output: Song files organized into album subdirectories

Key features:
Extracts album metadata using mid3v2
Creates sanitized folder names (removes special characters)
Falls back to unknown_album for files without metadata
Moves files (does not copy)

Configuration:
Edit the MUSIC_FOLDER variable at the top.

group_by_artist.sh
Input: Music folder with album subdirectories
Output: Album folders grouped under artist subdirectories

Key features:
Reads first song's artist metadata from each album folder
Creates an Artists directory to hold all artist folders
Sanitizes illegal filesystem characters: / : * ? " < > | → _
Skips Artists and Compilations folders to prevent recursive issues
Uses mapfile to safely capture folders before iteration
Moves folders (does not copy)

Configuration:
Edit the MUSIC_FOLDER variable at the top.

Troubleshooting
Error: "Music folder does not exist"
Cause: The MUSIC_FOLDER path is incorrect or the folder doesn't exist.

Solution:
Open the script in a text editor
Check the MUSIC_FOLDER variable
Verify the path exists: ls -la /path/to/folder
Update the path if necessary

Error: "command not found: mid3v2"
Cause: The mutagen package is not installed.

Solution:
bash
sudo apt-get install mutagen

Error: "command not found: ffmpeg"
Cause: ffmpeg is not installed.

Solution:
bash
sudo apt-get install ffmpeg

Error: "Permission denied" when running scripts
Cause: Scripts are not executable.

Solution:
bash
chmod +x *.sh

Error: "Permission denied" when moving files
Cause: You don't have write permissions on the music folder.

Solution:
bash
# Check permissions
ls -la /path/to/music/folder

# If you don't own it, take ownership
sudo chown -R \$USER:\$USER /path/to/music/folder

WMA conversion is very slow
Why: ffmpeg re-encodes audio in real-time. Speed depends on:

Number of files
File sizes
CPU speed
Audio bitrate (higher quality = slower)
Normal timing: Typically 1-5 minutes per GB of music.

How do I undo/rollback changes*
Important: These scripts permanently move files. There is no built-in undo.

Best practices:

Always test on a backup first — Copy a small subset of your library to a test folder and run the scripts there
Keep originals until satisfied — Don't delete your original music files until you've verified the organized result
Version control the scripts — Use git to track script changes (not music files)

If files are moved to the wrong location, use the file manager or mv command to manually relocate them:

bash

mv /path/to/wrong/location/file.mp3 /path/to/correct/location/

Supported File Formats
Conversion:

WMA → MP3 (via ffmpeg)
Organization (by default):
MP3, FLAC, OGG, M4A
To add more formats:
Edit both scripts and update the file extension loop*

bash
for music\_file in "\$MUSIC\_FOLDER"/*.{mp3,flac,ogg,m4a,wav}; do

Add or remove extensions as needed.

Performance Tips

Large Libraries (10,000+ files)
Consider:
Run scripts on a local drive (not network storage for speed)
Close other applications to free up CPU and RAM
If very large, split your library and run scripts on chunks separately
Monitor Progress
To see activity in real-time, open another terminal and run:

bash
watch -n 1 "find /path/to/music -type d | wc -l"

This updates every second showing the number of directories created.

License
This project is released under the MIT License. See the LICENSE file for details.

Contributing

Found a bug or have an improvement? Please:

Test thoroughly on a backup copy first
Document the issue with exact error messages and steps to reproduce
Propose a fix or improvement
Changelog
v1.0.0 (Initial Release)
WMA to MP3 conversion script
Album organization script
Artist grouping script
Comprehensive documentation and troubleshooting guide
Questions? Review the Usage and Troubleshooting sections above for most common issues.

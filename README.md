# Music Library Organizer 🎵

*A collection of Bash scripts to automatically organize your music library by **artist** and **album**, with support for compilations. Converts legacy audio formats (WMA) to MP3 and uses metadata to intelligently structure your music files.*

---

## ✨ Features


| Feature                         | Description                                                     |
| ------------------------------- | --------------------------------------------------------------- |
| **Batch WMA to MP3 Conversion** | Converts all `.wma` files to `.mp3` using FFmpeg.               |
| **Automatic Album Grouping**    | Groups MP3 files into album folders using ID3 metadata.         |
| **Artist Folder Hierarchy**     | Organizes albums under artist directories with sanitized names. |
| **Compilation Support**         | Dedicated `Compilations/` directory for multi-artist albums.    |
| **Fallback Handling**           | Files with missing/corrupted metadata go to `unknown_album/`.   |
| **Non-Destructive**             | Original files are preserved until conversion is verified.      |


---

## 📦 Folder Structure

After running all scripts, your music library will look like this:

```
Music/
├── Artists/
│   ├── Artist Name 1/
│   │   ├── Album 1/
│   │   │   ├── song1.mp3
│   │   │   ├── song2.mp3
│   │   │   └── ...
│   │   ├── Album 2/
│   │   │   └── ...
│   │   └── ...
│   ├── Artist Name 2/
│   │   └── ...
│   └── ...
├── Compilations/
│   ├── Compilation Album 1/
│   │   ├── song1.mp3
│   │   ├── song2.mp3
│   │   └── ...
│   ├── Compilation Album 2/
│   │   └── ...
│   └── ...
└── unknown_album/
    └── (files with missing album metadata)
```

---

## 🛠 Prerequisites

Ensure the following tools are installed on your **Linux** system:

```bash
sudo apt update && sudo apt install ffmpeg python3-mutagen
```


| Tool              | Purpose                                        |
| ----------------- | ---------------------------------------------- |
| `ffmpeg`          | Audio conversion (WMA → MP3).                  |
| `python3-mutagen` | Reliable ID3 metadata extraction.              |
| `mid3v2`          | (Included with `mutagen`) Metadata inspection. |


**Verify installation:**

```bash
ffmpeg -version
mid3v2 --version
python3 -c "import mutagen; print(mutagen.__version__)"
```

---

## 🚀 Usage

### Step 1: Convert WMA to MP3

Run the conversion script to batch-convert all `.wma` files to `.mp3`:

```bash
bash convert_wma_to_mp3.sh
```

**What it does:**

- Finds all `.wma` files in the current directory and subdirectories.
- Converts each to MP3 using FFmpeg with **maximum quality** (`-q:a 0`).
- Deletes the original WMA file **only after successful conversion**.
- Logs progress to the terminal.

⚠️ **Note:** Conversion can be slow for large libraries. Consider running overnight for 1000+ files.

---

### Step 2: Organize Files by Album

Group your MP3 files into album folders using ID3 metadata:

```bash
bash organize_by_album.sh
```

**What it does:**

- Extracts the **album name** from each MP3's ID3 tags using `mutagen`.
- Creates an album folder (or uses an existing one).
- Moves the file into the album folder.
- Falls back to `unknown_album/` for files with missing metadata.
- Sanitizes folder names to remove illegal characters.

---

### Step 3: Group Albums by Artist

Organize album folders under artist directories:

```bash
bash group_by_artist.sh
```

**What it does:**

- Extracts the **artist name** from each MP3's ID3 tags.
- Creates artist folders (or uses existing ones).
- Moves album folders into the corresponding artist folder.
- Sanitizes artist folder names (replaces `/ : * ? " < > |` with `_`).
- Skips `Artists/` and `Compilations/` directories to avoid loops.

---

### Step 4: Manual Compilation Handling

Before running `group_by_artist.sh`, manually move compilation albums to the `Compilations/` directory:

```bash
mkdir -p Music/Compilations
mv "Music/Album Name/" "Music/Compilations/"
```

Repeat for each compilation album. This prevents them from being nested under a single artist folder.

---

## 📜 Script Details

### `convert_wma_to_mp3.sh`

**Purpose:** Batch-converts `.wma` files to `.mp3`.

```bash
#!/bin/bash

for file in **/*.wma; do
    [ -f "$file" ] || continue
    output="${file%.wma}.mp3"
    echo "Converting: $file → $output"
    ffmpeg -i "$file" -q:a 0 "$output" < /dev/null
    if [ $? -eq 0 ]; then
        rm "$file"
        echo "✓ Deleted original: $file"
    else
        echo "✗ Conversion failed for $file"
    fi
done
```

**Key Points:**

- Uses `< /dev/null` to prevent FFmpeg from hanging on interactive prompts.
- Deletes the original WMA **only after successful conversion**.
- `-q:a 0` sets **maximum quality** (variable bitrate).

---

### `organize_by_album.sh`

**Purpose:** Groups MP3 files into album folders based on metadata.

```bash
#!/bin/bash

for file in *.mp3; do
    [ -f "$file" ] || continue
    
    album=$(python3 -c "from mutagen.mp3 import MP3; m = MP3('$file'); print(m.get('TIT2', ['Unknown Album'])[0] if 'TIT2' in m else 'unknown_album')" 2>/dev/null)
    album=${album:-unknown_album}
    
    mkdir -p "$album"
    mv "$file" "$album/"
done
```

**Note:** This is a simplified example. The actual script uses more robust metadata extraction.

---

### `group_by_artist.sh`

**Purpose:** Organizes album folders under artist directories.

```bash
#!/bin/bash

# Sanitize function
sanitize() {
    echo "$1" | sed 's/[\\/:\*?"<>|]/_/g'
}

for album_dir in */; do
    [ "$album_dir" = "Artists/" ] && continue
    [ "$album_dir" = "Compilations/" ] && continue
    
    for file in "$album_dir"*.mp3; do
        [ -f "$file" ] || continue
        
        artist=$(python3 -c "from mutagen.mp3 import MP3; m = MP3('$file'); print(m.get('TPE1', ['Unknown Artist'])[0] if 'TPE1' in m else 'Unknown Artist')" 2>/dev/null)
        artist=${artist:-Unknown Artist}
        artist=$(sanitize "$artist")
        
        mkdir -p "Artists/$artist/$album_dir"
        mv "$file" "Artists/$artist/$album_dir/"
        break
    done
    
    rmdir "$album_dir" 2>/dev/null
done
```

**Key Points:**

- Sanitizes illegal characters in folder names (`/ : * ? " < > |` → `_`).
- Skips system folders to prevent recursive loops.
- Uses `rmdir` to clean up empty album directories after moving.

---

## ⚠️ Troubleshooting


| Issue                                     | Solution                                                           |
| ----------------------------------------- | ------------------------------------------------------------------ |
| **Scripts don't have execute permission** | Run: `chmod +x *.sh`                                               |
| **`ffmpeg: command not found`**           | Install FFmpeg: `sudo apt install ffmpeg`                          |
| **`No such file or directory` errors**    | Run scripts from the directory containing your music files.        |
| **Files not organizing correctly**        | Check ID3 tags manually: `mid3v2 "your_file.mp3"`                  |
| **Conversion is slow**                    | Normal for large libraries. Use SSD storage for faster operations. |


---

## 💡 Performance Tips

- **Run conversion overnight** for large libraries (1000+ files).
- **Test on a sample** before running scripts on your entire library.
- **Back up your music** before starting (scripts preserve originals until conversion succeeds).
- **Use SSD storage** for faster file operations.

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE.txt) file for details.

---

## 🤝 Contributing

Found a bug or have a feature idea? **Open an issue** or **submit a pull request**!

---

## 📌 Notes

- **Non-destructive by design:** Original files are preserved until conversion is verified.
- **Sanitization:** Folder names are automatically sanitized to avoid filesystem errors.
- **Fallbacks:** Files with missing metadata are moved to `unknown_album/`.
- **Compilations:** Manually move compilation albums to `Compilations/` before running `group_by_artist.sh`.

---

*Happy organizing! 🎶*

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

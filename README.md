# DaVinci Resolve Insta360 / DJI Timecode Batch Updater

Automatically extract and set timecode metadata from Insta360 and DJI video filenames in DaVinci Resolve.

## Overview

This Lua script automates the tedious process of setting timecode for Insta360 and DJI footage in DaVinci Resolve. Instead of manually entering timecode for each clip, the script intelligently parses the timestamp embedded in your filenames and applies it as the Start Timecode in your media pool. The format is auto-detected per clip, so mixed Insta360 + DJI selections work in a single run.

### Why This Matters

Insta360 and DJI cameras both write a filming timestamp into their filenames. This script leverages that metadata to automatically populate semi-accurate timecode information, which is essential for:
- Syncing multi-camera footage (e.g. Insta360 + DJI in the same shoot)
- Maintaining timeline references
- Streamlining post-production workflows
- Batch processing large footage libraries

## Features

✅ **Automatic Timecode Extraction** - Parses HH:MM:SS from Insta360 and DJI filenames  
✅ **Multi-Camera Support** - Auto-detects Insta360 vs DJI per clip in one batch  
✅ **Batch Processing** - Update multiple clips in one operation  
✅ **Cross-Platform Support** - Works on Windows, macOS, and Linux  
✅ **Error Handling** - Detailed logging for successful and failed operations  
✅ **Non-Destructive** - Only modifies timecode metadata, not media files  
✅ **User-Friendly Output** - Clear feedback on what was processed  

## Filename Patterns

The script auto-detects which camera produced each clip based on the filename.

### Insta360

```
VID_YYYYMMDD_HHMMSS_XX_YYY.mp4
VID_20251130_104916_00_004.mp4
VID_20251130_111242_00_005.mp4
VID_20251130_133049_00_016_017.mp4
```

Where:
- `YYYYMMDD` = Date (film date)
- `HHMMSS` = Time in 24-hour format (this becomes your timecode)
- `XX` = Audio channel indicator
- `YYY` = Clip sequence number

### DJI

```
CAM_YYYYMMDDHHMMSS_NNNN_D.mp4
DJI_YYYYMMDDHHMMSS_NNNN_D.mp4
CAM_20260202095309_0008_D.mp4   →  09:53:09
DJI_20260204215844_0026_D.mp4   →  21:58:44
```

Where:
- `CAM` / `DJI` = Camera prefix (both are accepted)
- `YYYYMMDDHHMMSS` = Date and time concatenated (the trailing `HHMMSS` becomes your timecode)
- `NNNN` = Clip sequence number
- `D` = DJI suffix

## Requirements

- **DaVinci Resolve** (version 18.0 or later recommended) — Lua is bundled, no separate install needed
- Media clips in your DaVinci Resolve project with Insta360 or DJI naming convention

## Installation

### Step 1: Locate Your Scripts Folder

**Windows:**
```
%APPDATA%\Blackmagic Design\DaVinci Resolve\Support\Fusion\Scripts\Utility
```
Quick access: Press `Win + R`, paste the path above, press Enter

**macOS:**
```
~/Library/Application Support/Blackmagic Design/DaVinci Resolve/Fusion/Scripts/Utility
```
Quick access: Open Finder → `Cmd + Shift + G` → paste the path above

**Linux:**
```
~/.local/share/DaVinciResolve/Fusion/Scripts/Utility
```

### Step 2: Download and Save the Script

1. Download `BatchUpdateTimecode-DJI-Insta360.lua` from this repository
2. Place it in the `Utility` folder (see Step 1)
3. Restart DaVinci Resolve completely

### Step 3: Verify Installation

1. Open DaVinci Resolve
2. Go to **Workspace → Scripts → Utility**
3. You should see "BatchUpdateTimecode-DJI-Insta360" in the menu

## Usage

1. **Import Your Footage**
   - Import your Insta360 and/or DJI video files into your DaVinci Resolve Media Pool
   - Ensure filenames follow one of the supported patterns shown above

2. **Select Clips**
   - In the Media Pool, select one or more clips you want to update
   - You can multi-select by holding `Ctrl` (Windows) or `Cmd` (macOS)
   - Insta360 and DJI clips can be selected together — the script auto-detects each

3. **Run the Script**
   - Go to **Workspace → Scripts → Utility → BatchUpdateTimecode-DJI-Insta360**
   - The script will process your selected clips

4. **Review Results**
   - Check the script output in the console for success/failure messages
   - Verify timecode was applied correctly (check **Clip Properties**)

### Example Output

```
Found 4 selected clip(s)
------------------------------------------------------------
✓ SUCCESS [Insta360]: VID_20251130_104916_00_004.mp4
  Extracted Time: 104916 → 10:49:16:00

✓ SUCCESS [Insta360]: VID_20251130_133049_00_016_017.mp4
  Extracted Time: 133049 → 13:30:49:00

✓ SUCCESS [DJI]: CAM_20260202095309_0008_D.mp4
  Extracted Time: 095309 → 09:53:09:00

✓ SUCCESS [DJI]: DJI_20260204215844_0026_D.mp4
  Extracted Time: 215844 → 21:58:44:00

------------------------------------------------------------
Processing complete:
 Success: 4
 Failed: 0
 Total: 4
```

## Troubleshooting

### Script Doesn't Appear in Menu

- **Solution 1:** Ensure the script is in the correct `Utility` subfolder (not just the parent `Scripts` folder)
- **Solution 2:** Restart DaVinci Resolve completely
- **Solution 3:** Check file extension is `.lua` (not `.txt`)

### "No Clips Selected" Error

- Make sure you have clips selected in the Media Pool
- Click on a clip to highlight it before running the script

### Timecode Not Updating

- Verify your filenames match one of the supported patterns:
  - Insta360: `VID_YYYYMMDD_HHMMSS_XX_YYY.mp4`
  - DJI: `CAM_YYYYMMDDHHMMSS_NNNN_D.mp4` or `DJI_YYYYMMDDHHMMSS_NNNN_D.mp4`
- Check that the date/time portion is valid (not corrupted filenames)
- Ensure clips are stored in the Media Pool (not just in bins on the timeline)

### "Could Not Connect to DaVinci Resolve"

- Make sure DaVinci Resolve is open and running
- Try restarting DaVinci Resolve
- Check that scripting is enabled in **Preferences → System → General**

## How It Works

The script performs these steps:

1. **Connects to DaVinci Resolve** via the Scripting API
2. **Gets Selected Clips** from your Media Pool
3. **Detects Camera** by matching the filename against Insta360 and DJI patterns
4. **Parses Filename** using Lua patterns to extract the HHMMSS timestamp
5. **Converts Timecode** from HHMMSS to HH:MM:SS:00 format (DaVinci Resolve standard)
6. **Sets Start TC** property on each clip
7. **Reports Results** with detailed success/failure information (including which camera was detected)

## Technical Details

### Timecode Format

- **Input:** `HHMMSS` (e.g., `104916` = 10:49:16)
- **Output:** `HH:MM:SS:00` (e.g., `10:49:16:00`)
- The `:00` represents the frames component (DaVinci Resolve sets the project frame rate; the script always uses `:00`)

### Lua Patterns

Lua patterns lack regex's `\d{n}` quantifier and `(?:A|B)` alternation, so digit runs are spelled out and the two DJI prefixes are tried in turn.

DJI (`CAM_YYYYMMDDHHMMSS_NNNN_D` or `DJI_YYYYMMDDHHMMSS_NNNN_D`):

```lua
"^CAM_%d%d%d%d%d%d%d%d(%d%d%d%d%d%d)_%d+_D"
"^DJI_%d%d%d%d%d%d%d%d(%d%d%d%d%d%d)_%d+_D"
```

Insta360 (`VID_YYYYMMDD_HHMMSS_XX_YYY`):

```lua
"^VID_%d%d%d%d%d%d%d%d_(%d%d%d%d%d%d)_"
```

DJI is checked first; if neither matches, the clip is skipped.

## Platform-Specific Notes

### Windows
- Uses standard environment variables for path resolution
- Supports both user-level and system-level script installations

### macOS
- May need full disk access permissions for script access

### Linux
- Works with DaVinci Resolve installation in standard locations
- Supports both user (`~/.local/share`) and system (`/opt/resolve`) paths

## Related Resources

- [DaVinci Resolve Scripting API Documentation](https://www.blackmagicdesign.com/developer/product/davinci-resolve/)
- [DaVinci Resolve Official Support](https://www.blackmagicdesign.com/support/)
- [Insta360 Official Documentation](https://www.insta360.com/)
- [DJI Official Documentation](https://www.dji.com/)

## Contributing

Found a bug or have suggestions? Feel free to open an issue or submit a pull request!

## License

This script is provided as-is for personal and commercial use. Modify and distribute as needed.

## Disclaimer

This script modifies metadata in your DaVinci Resolve project. Always test on a backup project first. The author is not responsible for any data loss or project corruption.

---

**Happy editing! 🎬**
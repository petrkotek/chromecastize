chromcastize
============
Simple bash script to convert video files into Google Chromecast supported format.

Script identifies video and audio format of given file (using `mediainfo`) and converts it if necessary (using `ffmpeg`).

Filename of output video file is `<original_filename>.mkv` and original video file gets renamed to `<original_filename>.bak`.

Requirements
------------
- `mediainfo`
- `ffmpeg`

Usage
-----
```
./chromecastize.sh <videofile1> [videofile2 ...]
```

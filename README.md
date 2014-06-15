chromcastize
============
Simple bash script to convert video files into Google Chromecast supported format.

Script identifies video and audio format of given file (using `mediainfo`) and converts it if necessary (using `ffmpeg`).

Filename of output video file is `<original_filename>.mkv` and original video file gets renamed to `<original_filename>.bak`.

Requirements
------------
- `mediainfo`
- `ffmpeg`

Install requirements by running e.g. `apt-get install ffmpeg mediainfo` (Debian) or `brew install ffmpeg mediainfo` (MacOS with Homebrew).

Usage
-----
```
./chromecastize.sh <videofile1> [videofile2 ...]
```

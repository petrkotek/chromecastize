chromecastize
=============
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
./chromecastize.sh [--mp4 | --mkv | --stereo | --delete-on-success | --force-vencode | --force-aencode | --config=/path/to/config] <videofile1> [videofile2 ...]
```

### Examples:
- `./chromecastize.sh /Volumes/MyNAS` - converts all videos on your NAS (assuming that it's mounted to `/Volumes/MyNAS`)
- `./chromecastize.sh Holiday.avi Wedding.avi` - converts specified video files

### Options:
- `--mp4` forces conversion to MPEG-4 container
- `--mkv` forces conversion to Matroska container
- `--stereo` forces conversion from multichannel audio to 2 channel stereo
- `--delete-on-success` deletes the original file on success instead of renaming it to `<original_filename>.bak`
- `--force-vencode` forces re-encoding of the video, if the codec is supported but the profile level is too high
- `--force-aencode` forces re-encoding of the audio
- `--config=/path/to/config` specify where to store configuration. When omitted the default folder `~/.chromecastize` is used.

Changing default options
------------------------
- Copy the example `config.sh` file to your config folder (default location: `~/.chromecastize`).
- Uncomment the options which you wish to change by removing the leading `#` symbol.

Authors
-------
- **Petr Kotek** (did the script save you some time? donations appreciated: www.petrkotek.com)

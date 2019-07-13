#!/bin/bash
#
# Example configuration file for chromecastize.
#
# In order to customize the default options that are used by chromecastize, copy
# this file to your config folder (default location is `$HOME/.chromecastize/`)
# and uncomment the relevant options below.

# The 'General' formats that are supported by your Chromecast. This is also
# known as the 'container' format. These match the formats that are reported by
# the `mediainfo` library. If you are trying to encode a file that uses a format
# which is not included in this list, then it will be automatically recoded
# using the `DEFAULT_GFORMAT` (see below).
#
# Full list of possible values, second column should contain `M`:
# https://github.com/MediaArea/MediaInfoLib/blob/master/Source/Resource/Text/DataBase/Format.csv
#
# Official documentation of supported formats:
# https://developers.google.com/cast/docs/media#media_container_formats
#
# Default value (suitable for any Chromecast):
#SUPPORTED_GFORMATS=('MPEG-4' 'Matroska' 'WebM')

# The codec to use if the original general format is not supported.
#
# For a full list of possible values, execute the following command:
# ffmpeg -formats
#
# Official documentation of supported formats:
# https://developers.google.com/cast/docs/media#media_container_formats
#
# Default value (suitable for any Chromecast):
#DEFAULT_GFORMAT=mkv

# The video formats that are supported by your Chromecast. These match the
# formats that are reported by the `mediainfo` library. If you are trying to
# encode a file that uses a format which is not included in this list, then it
# will be automatically recoded using the `DEFAULT_VFORMAT` (see below).
#
# Full list of possible values, second column should contain `V`:
# https://github.com/MediaArea/MediaInfoLib/blob/master/Source/Resource/Text/DataBase/Codec.csv
#
# Official documentation of supported formats:
# https://developers.google.com/cast/docs/media#video_codecs
#
# Default value (suitable for any Chromecast):
#SUPPORTED_VCODECS=('AVC' 'VP8')

# The video codec to use if the original one is not supported.
#
# For a full list of possible values, execute the following command:
# ffmpeg -codecs | grep "^[[:blank:]]*DEV"
#
# Official documentation of supported formats:
# https://developers.google.com/cast/docs/media#video_codecs
#
# Default value (suitable for any Chromecast):
#DEFAULT_VCODEC=h264

# Video encoding options to pass to ffmpeg. The available options depend on the
# video codec. See the FFMPEG documentation for more info on your chosen codec.
# If you use h264, see https://trac.ffmpeg.org/wiki/Encode/H.264
#
# Default value for h264 (suitable for any Chromecast):
#DEFAULT_VCODEC_OPTS="-preset fast -profile:v high -level 4.1 -crf 17 -pix_fmt yuv420p"

# The audio formats that are supported by your Chromecast. These match the
# formats that are reported by the `mediainfo` library. If you are trying to
# encode a file that uses a format which is not included in this list, then it
# will be automatically recoded using the `DEFAULT_AFORMAT` (see below).
#
# Full list of possible values, second column should contain `A`:
# https://github.com/MediaArea/MediaInfoLib/blob/master/Source/Resource/Text/DataBase/Codec.csv
#
# Official documentation of supported formats:
# https://developers.google.com/cast/docs/media#audio_codecs
#
# Default value (suitable for any Chromecast):
#SUPPORTED_ACODECS=('AAC' 'MPEG Audio' 'Vorbis' 'Ogg' 'Opus')

# The audio codec to use if the original one is not supported.
#
# For a full list of possible values, execute the following command:
# ffmpeg -codecs | grep "^[[:blank:]]*DEA"
#
# Official documentation of supported formats:
# https://developers.google.com/cast/docs/media#audio_codecs
#
# Default value (suitable for any Chromecast):
#DEFAULT_ACODEC=libvorbis

# Audio encoding options to pass to ffmpeg. The available options depend on the
# audio codec. See the FFMPEG documentation for more info on your chosen codec.
#
# Default value (suitable for any Chromecast):
#DEFAULT_ACODEC_OPTS=""

# Option to force re-encoding of the video stream. Uncomment this if you want to
# ensure that the video will always be using your encoding options and the
# resulting bitrate will be supported by your device.
#FORCE_VENCODE=1

# Option to force re-encoding of the audio stream.
#FORCE_AENCODE=1

# Option to recode multichannel audio to stereo. Use this if you have problems
# playing multichannel audio on your device, or if you do not have a surround
# setup.
# STEREO=1

# What to do on successful conversion?
# Options are:
#  - bak (default) - will move the original file to a .bak extension
#  - delete - will delete the original file and just keep the converted file
#ONSUCCESS=bak

# Suggested options for Chromecast Gen. 1 and Gen 2.
#SUPPORTED_GFORMATS=('MPEG-4' 'Matroska' 'WebM')
#DEFAULT_GFORMAT=mkv
#SUPPORTED_VCODECS=('AVC' 'VP8')
#DEFAULT_VCODEC=h264
#DEFAULT_VCODEC_OPTS="-preset fast -profile:v high -level 4.1 -crf 17 -pix_fmt yuv420p"
#SUPPORTED_ACODECS=('AAC' 'MPEG Audio' 'Vorbis' 'Ogg' 'Opus')
#DEFAULT_ACODEC=libvorbis

# Suggested options for Chromecast Gen. 3.
#SUPPORTED_GFORMATS=('MPEG-4' 'Matroska' 'WebM')
#DEFAULT_GFORMAT=mkv
#SUPPORTED_VCODECS=('AVC' 'VP8')
#DEFAULT_VCODEC=h264
#DEFAULT_VCODEC_OPTS="-preset fast -profile:v high -level 4.2 -crf 17 -pix_fmt yuv420p"
#SUPPORTED_ACODECS=('AAC' 'MPEG Audio' 'Vorbis' 'Ogg' 'Opus')
#DEFAULT_ACODEC=libvorbis

# Suggested options for Chromecast Ultra.
#SUPPORTED_GFORMATS=('MPEG-4' 'Matroska' 'WebM')
#DEFAULT_GFORMAT=mkv
#SUPPORTED_VCODECS=('AVC' 'HEVC' 'VP8' 'VP9')
#UNSUPPORTED_VCODECS=('MPEG-4 Visual' 'xvid' 'MPEG Video')
#DEFAULT_VCODEC=libx265
#DEFAULT_VCODEC_OPTS="-preset fast -level 5.2 -crf 17"
#SUPPORTED_ACODECS=('AAC' 'MPEG Audio' 'Vorbis' 'Ogg' 'Opus')
#DEFAULT_ACODEC=libvorbis

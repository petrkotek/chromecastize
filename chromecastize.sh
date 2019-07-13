#!/bin/bash

##########
# CONFIG #
##########
CONFIG_DIRECTORY=~/.chromecastize
SUPPORTED_EXTENSIONS=('mkv' 'avi' 'mp4' '3gp' 'mov' 'mpg' 'mpeg' 'qt' 'wmv' 'm2ts' 'flv' 'webm')

SUPPORTED_GFORMATS=('MPEG-4' 'Matroska' 'WebM')
UNSUPPORTED_GFORMATS=('BDAV' 'AVI' 'Flash Video' 'DivX')

SUPPORTED_VCODECS=('AVC' 'VP8')
UNSUPPORTED_VCODECS=('MPEG-4 Visual' 'xvid' 'MPEG Video' 'HEVC')

SUPPORTED_ACODECS=('AAC' 'MPEG Audio' 'Vorbis' 'Ogg' 'Opus')
UNSUPPORTED_ACODECS=('AC-3' 'DTS' 'E-AC-3' 'PCM' 'TrueHD')

ONSUCCESS=bak

DEFAULT_VCODEC=h264
# 1st and 2nd generation chromecasts and home hub https://developers.google.com/cast/docs/media
DEFAULT_VCODEC_OPTS="-preset fast -profile:v high -level 4.1 -crf 17 -pix_fmt yuv420p"
DEFAULT_ACODEC=libvorbis
DEFAULT_ACODEC_OPTS=""
DEFAULT_GFORMAT=mkv

#############
# FUNCTIONS #
#############

# Check if a value exists in an array
# @param $1 mixed  Needle
# @param $2 array  Haystack
# @return  Success (0) if value exists, Failure (1) otherwise
# Usage: in_array "$needle" "${haystack[@]}"
# See: http://fvue.nl/wiki/Bash:_Check_if_array_element_exists
in_array() {
	local hay needle=$1
	shift
	for hay; do
		[[ $hay == $needle ]] && return 0
	done
	return 1
}

print_help() {
	echo "Usage: chromecastize.sh [--mp4 | --mkv | --stereo | --force-vencode | --force-aencode | --config=/path/to/config/] <videofile1> [videofile2 ...]"
}

unknown_codec() {
	echo "'$1' is an unknown codec. Please add it to the list in a CONFIG section."
}

missing_config_directory() {
	echo 'Missing config directory.'
	print_help
}

is_supported_gformat() {
	if in_array "$1" "${SUPPORTED_GFORMATS[@]}"; then
		return 0
	elif in_array "$1" "${UNSUPPORTED_GFORMATS[@]}"; then
		return 1
	else
		unknown_codec "$1"
		exit 1
	fi
}

is_supported_vcodec() {
	if in_array "$1" "${SUPPORTED_VCODECS[@]}"; then
		return 0
	elif in_array "$1" "${UNSUPPORTED_VCODECS[@]}"; then
		return 1
	else
		unknown_codec "$1"
		exit 1
	fi
}

is_supported_acodec() {
	# Support for multichannel AAC audio has been removed in firmware 1.28.
	# Ref. https://issuetracker.google.com/issues/69112577#comment4
	if [ "$1" = "AAC" ] && [ "$2" -gt 2 ]; then
		return 1
	elif in_array "$1" "${SUPPORTED_ACODECS[@]}"; then
		return 0
	elif in_array "$1" "${UNSUPPORTED_ACODECS[@]}"; then
		return 1
	else
		unknown_codec "$1"
		exit 1
	fi
}

is_supported_ext() {
	EXT=`echo $1 | tr '[:upper:]' '[:lower:]'`
	in_array "$EXT" "${SUPPORTED_EXTENSIONS[@]}"
}

mark_as_good() {
	# add file as successfully converted
	echo `$REALPATH "$1"` >> "$PROCESSED_FILES"
}

on_success() {
	echo ""
	FILENAME="$1"
	DESTINATION_FILENAME="$2"
	echo "- conversion succeeded; file '$DESTINATION_FILENAME' saved"
	if [ "$ONSUCCESS" = "delete" ]; then
		echo "- deleting original file"
		rm -f "$FILENAME"
	else
		echo "- renaming original file as '$FILENAME.bak'"
		mv "$FILENAME" "$FILENAME.bak"	
	fi
	mv "$FILENAME.$OUTPUT_GFORMAT" "$DESTINATION_FILENAME"
	mark_as_good "$DESTINATION_FILENAME"
}

on_failure() {
	echo ""
	FILENAME="$1"
	echo "- failed to convert '$FILENAME' (or conversion has been interrupted)"
	echo "- deleting partially converted file..."
	rm "$FILENAME.$OUTPUT_GFORMAT" &> /dev/null
}

process_file() {
	local FILENAME="$1"

	echo "==========="
	echo "Processing: $FILENAME"

	# test extension
	BASENAME=$(basename "$FILENAME")
	EXTENSION="${BASENAME##*.}"
	if ! is_supported_ext "$EXTENSION"; then
		echo "- not a video format, skipping"
		return
	fi

	# test if it's an `chromecastize` generated file
	if grep -Fxq "`$REALPATH "$FILENAME"`" "$PROCESSED_FILES"; then
		echo '- file was generated by `chromecastize`, skipping'
		return
	fi

	# test general format
	INPUT_GFORMAT=`mediainfo --Inform="General;%Format%\n" "$FILENAME" 2> /dev/null | head -n1`
	if is_supported_gformat "$INPUT_GFORMAT" && [ "$OVERRIDE_GFORMAT" = "" ] || [ "$OVERRIDE_GFORMAT" = "$EXTENSION" ]; then
		OUTPUT_GFORMAT="ok"
	else
		# if override format is specified, use it; otherwise fall back to default format
		OUTPUT_GFORMAT="${OVERRIDE_GFORMAT:-$DEFAULT_GFORMAT}"
	fi
	echo "- general: $INPUT_GFORMAT -> $OUTPUT_GFORMAT"

	# test video codec
	INPUT_VCODEC_PROFILE=`mediainfo --Inform="Video;%Format_Profile%\n" "$FILENAME" 2> /dev/null | head -n1`
	if [ -n "$INPUT_VCODEC_PROFILE" ]; then
		echo "- input video profile: $INPUT_VCODEC_PROFILE"
	fi

	INPUT_VCODEC=`mediainfo --Inform="Video;%Format%\n" "$FILENAME" 2> /dev/null | head -n1`
	ENCODER_OPTIONS=""
	if is_supported_vcodec "$INPUT_VCODEC" && [ -z "$FORCE_VENCODE" ]; then
		OUTPUT_VCODEC="copy"
	else
		OUTPUT_VCODEC="$DEFAULT_VCODEC"
		ENCODER_OPTIONS=$DEFAULT_VCODEC_OPTS
	fi
	echo "- video: $INPUT_VCODEC -> $OUTPUT_VCODEC"

	# test audio codec
	INPUT_ACODEC=`mediainfo --Inform="Audio;%Format%\n" "$FILENAME" 2> /dev/null | head -n1`
	INPUT_ACHANNELS=`mediainfo --Inform="Audio;%Channels%\n" "$FILENAME" 2> /dev/null | head -n1`
	if [ ! -z "$STEREO" ] && [ $INPUT_ACHANNELS -gt 2 ]; then
		OUTPUT_ACODEC="$DEFAULT_ACODEC"
		ENCODER_OPTIONS="$ENCODER_OPTIONS $DEFAULT_ACODEC_OPTS -ac 2"
	elif is_supported_acodec "$INPUT_ACODEC" "$INPUT_ACHANNELS" && [ -z "$FORCE_AENCODE" ]; then
		OUTPUT_ACODEC="copy"
	else
		OUTPUT_ACODEC="$DEFAULT_ACODEC"
		ENCODER_OPTIONS="$ENCODER_OPTIONS $DEFAULT_ACODEC_OPTS"
	fi
	echo "- audio: $INPUT_ACODEC -> $OUTPUT_ACODEC"

	if [ "$OUTPUT_VCODEC" = "copy" ] && [ "$OUTPUT_ACODEC" = "copy" ] && [ "$OUTPUT_GFORMAT" = "ok" ]; then
		echo "- file should be playable by Chromecast!"
		mark_as_good "$FILENAME"
	else
		echo "- video length: `mediainfo --Inform="General;%Duration/String3%" "$FILENAME" 2> /dev/null`"
		if [ "$OUTPUT_GFORMAT" = "ok" ]; then
			OUTPUT_GFORMAT=$EXTENSION
		fi

		# Define the destination filename, stripping the original extension.
		DESTINATION_FILENAME=${FILENAME%.$EXTENSION}.$OUTPUT_GFORMAT

		# Make sure the encoder options are not escaped with quotes.
		IFS=' ' read -r -a ENCODER_OPTIONS_ARRAY <<< "$ENCODER_OPTIONS"

		$FFMPEG -loglevel error -stats -i "$FILENAME" -map 0 -scodec copy -vcodec "$OUTPUT_VCODEC" -acodec "$OUTPUT_ACODEC" ${ENCODER_OPTIONS_ARRAY[@]} "$FILENAME.$OUTPUT_GFORMAT" && on_success "$FILENAME" "$DESTINATION_FILENAME" || on_failure "$FILENAME"
		echo ""
	fi
}

################
# MAIN PROGRAM #
################

# test if `mediainfo` is available
MEDIAINFO=`which mediainfo 2> /dev/null`
if [ -z $MEDIAINFO ]; then
	echo '`mediainfo` is not available, please install it'
	exit 1
fi

# test if `ffmpeg` is available
FFMPEG=`which avconv 2> /dev/null || which ffmpeg 2> /dev/null`
if [ -z $FFMPEG ]; then
	echo '`avconv` (or `ffmpeg`) is not available, please install it'
	exit 1
fi

# test if `grealpath` or `realpath` is available
REALPATH=`which realpath 2> /dev/null || which grealpath 2> /dev/null`
if [ -z $REALPATH ]; then
	echo '`grealpath` (or `realpath`) is not available, please install it'
	exit 1
fi

# Output help if no arguments were passed.
if [ $# -lt 1 ]; then
	print_help
	exit 1
fi

# Process options.
while :; do
	case $1 in
		-h|-\?|--help)
			print_help
			exit 0
			;;
		--mkv|--mp4)
			OVERRIDE_GFORMAT=${1:2}
			;;
		--force-vencode)
			FORCE_VENCODE=1
			;;
		--delete-on-success)
			ONSUCCESS=delete
			;;
		--force-aencode)
			FORCE_AENCODE=1
			;;
		--stereo)
			STEREO=1
			;;
		--config=?*)
			CONFIG_DIRECTORY=${1#*=}
			;;
		--config=)
			missing_config_directory
			exit 1
			;;
		--config)
			if [ "$2" ]; then
				CONFIG_DIRECTORY=$2
				shift
			else
				missing_config_directory
				exit 1
			fi
			;;
		# Ends all options. Everything that follows is considered a
		# filename.
		--)
			shift
			break
			;;
		-?*)
			echo "Unknown option $1"
			print_help
			exit 1
			;;
		*)
			break
	esac
	shift
done

# Ensure that our config directory exists and is writable.
if ! [ -e "$CONFIG_DIRECTORY" ]; then
	if ! mkdir -p "$CONFIG_DIRECTORY" &> /dev/null; then
		echo "Config directory $CONFIG_DIRECTORY does not exist and could not be created."
		exit 1
	fi
fi

if ! [ -d "$CONFIG_DIRECTORY" ]; then
	echo "Supplied config directory $CONFIG_DIRECTORY is not a directory."
	exit 1
fi

if ! [ -w "$CONFIG_DIRECTORY" ]; then
	echo "Config directory $CONFIG_DIRECTORY is not writeable."
	exit 1
fi

# Load default configuration if it exists.
if [ -f "$CONFIG_DIRECTORY/config.sh" ]; then
  . "$CONFIG_DIRECTORY/config.sh"
fi

# Ensure that the processed file list exists and is writeable.
PROCESSED_FILES="$CONFIG_DIRECTORY/processed_files"
if ! touch "$PROCESSED_FILES" &> /dev/null || ! [ -f "$PROCESSED_FILES" ] || ! [ -w "$PROCESSED_FILES" ]; then
	echo "Could not write to settings file $PROCESSED_FILES."
	exit 1
fi

# Process files.
for FILENAME in "$@"; do
	if ! [ -e "$FILENAME" ]; then
		echo "File not found ($FILENAME). Skipping..."
	elif [ -d "$FILENAME" ]; then
		ORIG_IFS=$IFS
		IFS=$(echo -en "\n\b")
		for F in $(find "$FILENAME" -type f); do
			process_file $F
		done
		IFS=$ORIG_IFS
	elif [ -f "$FILENAME" ]; then
		process_file "$FILENAME"
	else
		echo "Invalid file ($FILENAME). Skipping..."
	fi
done

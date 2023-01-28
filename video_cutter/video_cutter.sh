set -x

source="$1"
if [ -z "$source" ]; then
    echo need source
    exit 1
fi
shift 1

if [ -z $1 ]; then
    echo need time
    exit 1
fi

if [ "${source##*.}" == 'mkv' ]; then
    ext="mkv"
else
    ext="mp4"
fi

rename_output(){
    mv "output.${ext}" "${1%.*}.${ext}"
}

if [ $# -eq 1 ]; then
    ffmpeg -ss "$1" -i "$source" -c copy "output.${ext}"
    trash "$source"
    rename_output "$source"
    exit 0
fi

if [ $# -eq 2 ]; then
    ffmpeg -ss "$1" -to "$2" -i "$source" -c copy "output.${ext}"
    trash "$source"
    rename_output "$source"
    exit 0
fi

cnt=0

trash file

while [ -n "$1" ]; do
    time1="$1"
    shift 1
    cnt=$[cnt+1]
    outputname="${cnt}.${ext}"
    if [ -z "$1" ]; then
        ffmpeg -ss "$time1" -i "$source" -c copy "$outputname"
    else
        time2="$1"
        shift 1
        ffmpeg -ss "$time1" -to "$time2" -i "$source" -c copy "$outputname"
    fi
    echo "file '$outputname'" >> file
done

ffmpeg -f concat -i file -c copy "output.${ext}"
trash "$source"
while [ $cnt -ne 0 ]; do
    trash "${cnt}.${ext}"
    cnt=$[cnt-1]
done
trash file
rename_output "$source"

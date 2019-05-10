#!/bin/bash

if [ $# -eq 0 ]; then
    echo "<4>No file name specified"
    exit 1
fi

if mkdir "/tmp/candump.lock"; then
    echo "No candump-save service is already active"
else
    echo "A candump-save service is already active"
    exit 0
fi

dir="/tmp/candump/"
name="$1"

echo "Waiting for 10 seconds to obtain some more candump"
sleep 10

echo "Commanding multilog to rotate logs and waiting up to 10s..."
inotifywait -t 10 -e attrib /tmp/candump/current &>/dev/null &
pkill -SIGALRM multilog &
wait
echo "...done"

unset -v latest
unset -v previousLatest
for file in "$dir"*; do
    if [[ $file == $dir@* ]]; then
        [[ $file -nt $latest ]] && previousLatest=$latest && latest=$file
    fi
done

# Remark: If this service was called before multilog has rotated logs at least once
# on its own, previousLatest will be empty and thus cat will only take latest.
if [ "$name" == "manual" ]; then
    echo "Concatenating $previousLatest $latest and saving as full length PCAN trace file /mnt/data/candump/$name.trc"
    cat $previousLatest $latest > $dir$name.candump
else
    echo "Concatenating $previousLatest $latest and saving as size limited PCAN trace file /mnt/data/candump/$name.trc"
    cat $previousLatest $latest | tail -n 10000 > $dir$name.candump
fi

awk -f /etc/scripts/candump.awk $dir$name.candump > $dir$name.trc
rm $dir$name.candump
mkdir -p /mnt/data/candump
mv -f $dir$name.trc /mnt/data/candump/$name.trc

rm -r "/tmp/candump.lock"

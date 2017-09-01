#! /bin/bash

NAME=fwu
DESC="Firmware update over USB"

led1_blue ()
{
    echo "255" > /sys/class/leds/rgb1_blue/brightness || true
    echo "0" > /sys/class/leds/rgb1_green/brightness || true
    echo "0" > /sys/class/leds/rgb1_red/brightness || true
}

led1_off ()
{
    echo "0" > /sys/class/leds/rgb1_blue/brightness || true
    echo "0" > /sys/class/leds/rgb1_green/brightness || true
    echo "0" > /sys/class/leds/rgb1_red/brightness || true
}

led2_blue ()
{
    echo "255" > /sys/class/leds/rgb2_blue/brightness || true
    echo "0" > /sys/class/leds/rgb2_green/brightness || true
    echo "0" > /sys/class/leds/rgb2_red/brightness || true
}

led2_green ()
{
    echo "0" > /sys/class/leds/rgb2_blue/brightness || true
    echo "255" > /sys/class/leds/rgb2_green/brightness || true
    echo "0" > /sys/class/leds/rgb2_red/brightness || true
}

led2_red ()
{
    echo "0" > /sys/class/leds/rgb2_blue/brightness || true
    echo "0" > /sys/class/leds/rgb2_green/brightness || true
    echo "255" > /sys/class/leds/rgb2_red/brightness || true
}

led2_white ()
{
    echo "255" > /sys/class/leds/rgb2_blue/brightness || true
    echo "255" > /sys/class/leds/rgb2_green/brightness || true
    echo "255" > /sys/class/leds/rgb2_red/brightness || true
}

led2_off ()
{
    echo "0" > /sys/class/leds/rgb2_blue/brightness || true
    echo "0" > /sys/class/leds/rgb2_green/brightness || true
    echo "0" > /sys/class/leds/rgb2_red/brightness || true
}

display_done ()
{
    fbi --noverbose -T 1 /etc/images/done.png
    led2_green
}

display_error ()
{
    echo "...ERROR"
    led2_red
    fbi --noverbose -T 1 /etc/images/error.png
}

umount_sda ()
{
    if [ -d "/mnt/sda/autoupdate" ]; then
        echo "Unmounting sda..."
        if umount /mnt/sda; then
            echo "...done"
        else
            echo "...ERROR"
        fi
    else
        echo "Unmounting sda1..."
        if umount /mnt/sda1; then
            echo "...done"
        else
            echo "...ERROR"
        fi
    fi
}

part0_active ()
{
    echo "Setting partition 0 as active one..."
    if barebox-state -s partition=0; then
        echo "...done"
        umount_sda
        display_done
    else
        display_error
    fi
}

part1_active ()
{
    echo "Setting partition 1 as active one..."
    if barebox-state -s partition=1; then
        echo "...done"
        umount_sda
        display_done
    else
        display_error
    fi
}

case $1 in
start)
    if [ -d "/mnt/sda/autoupdate" ] || [ -d "/mnt/sda1/autoupdate" ]; then
        firstFile=""
        if [ -d "/mnt/sda/autoupdate" ]; then
            firstFile="/mnt/sda/autoupdate/$(ls /mnt/sda/autoupdate | head -n 1)"
        else
            firstFile="/mnt/sda1/autoupdate/$(ls /mnt/sda1/autoupdate | head -n 1)"
        fi
        if [[ $firstFile =~ .*medusa-image-[a-zA-Z0-9.-]+.rootfs.tar.gz$ ]]; then
            echo "Firmware tarball $firstFile found"
            if [[ $firstFile =~ .*$(cat /etc/medusa-version).rootfs.tar.gz$ ]]; then
                echo "Nothing to up- or downgrade"
            else
                if mountpoint -q /mnt/rfs_inactive; then
                    echo "Stopping DataServer based applications..."
                    systemctl stop medusa-DataServer
                    echo "Extracting firmware..."
                    led1_blue
                    led2_blue
                    fbi --noverbose -T 1 /etc/images/busy.png
                    rm -rf /tmp/rfs_inactive || true
                    mkdir /tmp/rfs_inactive
                    if tar -xf $firstFile -C /tmp/rfs_inactive; then
                        echo "...done"
                        echo "Rsyncing to inactive rfs partition..."
                        if rsync -a --delete /tmp/rfs_inactive/ /mnt/rfs_inactive/; then
                            echo "...done"
                            led2_blue
                            echo "Unmounting inactive rfs paritition..."
                            if umount /mnt/rfs_inactive; then
                                echo "...done"
                                echo "Swapping active partition..."
                                if df -T | grep 'ubi0:part0'; then
                                    part1_active
                                elif df -T | grep 'ubi0:part1'; then
                                    part0_active
                                else
                                    display_error
                                fi
                            else
                                display_error
                            fi
                        else
                            display_error
                        fi
                    else
                        display_error
                    fi
                else
                    display_error
                fi
            fi
        elif [[ $firstFile =~ .*medusa-image-[a-zA-Z0-9.-]+.rootfs.ubifs$ ]]; then
            echo "Firmware image $firstFile found"
            if [[ $firstFile =~ .*$(cat /etc/medusa-version).rootfs.ubifs$ ]]; then
                echo "Nothing to up- or downgrade"
            else
                echo "Stopping DataServer based applications..."
                systemctl stop medusa-DataServer
                led1_blue
                led2_white
                fbi --noverbose -T 1 /etc/images/busy.png
                echo "Unmounting inactive rfs paritition..."
                if umount /mnt/rfs_inactive; then
                    echo "...done"
                    echo "Updating firmware..."
                    if df -T | grep 'ubi0:part0'; then
                        echo "on ubi0_1..."
                        if ubiupdatevol /dev/ubi0_1 $firstFile; then
                            echo "...done"
                            echo "Swapping active partition..."
                            part1_active
                        else
                            display_error
                        fi
                    elif df -T | grep 'ubi0:part1'; then
                        echo "on ubi0_0..."
                        if ubiupdatevol /dev/ubi0_0 $firstFile; then
                            echo "...done"
                            echo "Swapping active partition..."
                            part0_active
                        else
                            display_error
                        fi
                    else
                        display_error
                    fi
                else
                    display_error
                fi
            fi
        fi
    fi
;;

stop)
    led1_off
    led2_off
;;

*)
    echo "Usage $0 {start|stop}"
    exit
esac

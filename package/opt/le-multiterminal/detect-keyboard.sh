#!/bin/bash

for i in /dev/input/*; do
    if test -c $i; then
        if udevadm info $i | grep -qw ID_INPUT_KEYBOARD; then
            echo $i
        fi
    fi
done

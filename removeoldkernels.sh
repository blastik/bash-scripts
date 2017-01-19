#!/bin/sh
prev=`readlink /vmlinuz.old` && prev=linux-image-${prev#*-}+
exec sudo apt-get -y purge '^linux-image-[0-9]' linux-image-`uname -r`+ $prev
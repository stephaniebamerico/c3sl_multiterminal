#!/usr/bin/make -f

export DEB_BUILD_MAINT_OPTIONS = hardening=+all
DPKG_EXPORT_BUILDFLAGS = 1
include /usr/share/dpkg/buildflags.mk
CC = gcc
CFLAGSS = -O2 -Wall -fPIC -pie $(CPPFLAGS) $(CFLAGS) $(LDFLAGS)
SRC=.
DST = ../usr/sbin
all:
	$(CC) $(CFLAGSS) $(SRC)/read-devices.c -o $(DST)/read-devices
	$(CC) $(CFLAGSS) $(SRC)/write-message.c -o $(DST)/write-message `pkg-config --libs --cflags cairo x11`
	$(CC) $(CFLAGSS) $(SRC)/seat-parent-window.c -o $(DST)/seat-parent-window `pkg-config --libs --cflags x11`
clean:
	rm -f $(DST)/read-devices 
	rm -f $(DST)/write-message 
	rm -f $(DST)/seat-parent-window

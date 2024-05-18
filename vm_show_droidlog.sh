#!/bin/bash
exec lxterminal -e "/system/bin/logcat|grep 'droidvm :'"

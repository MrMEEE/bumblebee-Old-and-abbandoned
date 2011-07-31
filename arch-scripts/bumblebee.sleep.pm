#!/bin/bash

HANDLER=/etc/rc.d/bumblebee

case "$1" in
	hibernate|suspend)
	   $HANDLER stop
		;;
	thaw|resume)
		$HANDLER start
		;;
	*) exit $NA
		;;
esac

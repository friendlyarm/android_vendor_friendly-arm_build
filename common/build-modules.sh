#!/bin/bash

KDIR=/opt/FriendlyARM/s5p4418/linux-3.4.y
TDIR=`pwd`
SELF=$0

#----------------------------------------------------------
# local functions

function usage()
{
	echo "Usage: $0 [ARGS]"
	echo ""
	echo "Options:"
	echo "  -h                    show this help message and exit"
	echo "  -k <kernel dir>       default: $KDIR"
	echo "  -d <android TOP dir>  default: PWD"
	echo "  clean                 make clean only"
}

function parse_args()
{
	TEMP=`getopt -o "k:d:h" -n "$SELF" -- "$@"`
	if [ $? != 0 ] ; then exit 1; fi
	eval set -- "$TEMP"

	while true; do
		case "$1" in
			-k ) KDIR=$2; shift 2;;
			-d ) TDIR=$2; shift 2;;
			-h ) usage; exit 1 ;;
			-- ) shift; break ;;
			*  ) echo "invalid option $1"; usage; return 1 ;;
		esac
	done
	if [ "x${1,,}" = "xclean" ]; then
		TARGET=clean
	fi
}

#----------------------------------------------------------

parse_args $@

TOP_VR=$TDIR/hardware/samsung_slsi/slsiap/prebuilt/modules/vr
TOP_CODA=$TDIR/vendor/nexell/s5p4418/modules/coda960

if [ ! -d $KDIR ]; then
	echo "Couldn't find kernel source: $KDIR"
	exit 1
fi

if [ ! -d $TOP_VR -o ! -d $TOP_CODA ]; then
	echo "Couldn't find module source.  Try at Android TOP dir or '-d <TOP dir>'"
	exit 1
fi

# build vr.ko
cd $TOP_VR && {
	if [ ! -f .version ]; then
		echo "r4p0-401" > .version
	fi
	make KDIR=$KDIR CROSS_COMPILE=arm-linux- \
		BUILD=release USING_UMP=0 USING_PROFILING=0 VR_SHARED_INTERRUPTS=1 \
		$TARGET
	cd - >/dev/null
}

# build nx_vpu.ko
cd $TOP_CODA && {
	make KDIR=$KDIR CROSS_COMPILE=arm-linux- ARCH=arm \
		$TARGET
	cd - >/dev/null
}

# show file info.
if [ -z $TARGET ]; then
	echo "--------------------------------------------------"
	ls -l $TOP_VR/*.ko $TOP_CODA/*.ko
fi


#!/bin/bash

if [[ "${1}" != "skip" ]] ; then
	./build_clean.sh
	./build_kernel.sh stock "$@" || exit 1
	./build_recovery.sh skip || exit 1
fi

VERSION="$(date +%F | sed s@-@@g)"

if [ -e boot.img ] ; then
	rm arter97-kernel-$VERSION.zip 2>/dev/null
	cp boot.img kernelzip/boot.img
	cp boot.img arter97-kernel-$VERSION.img
	cd kernelzip/
	7z a -mx0 arter97-kernel-$VERSION-tmp.zip *
	zipalign -v 4 arter97-kernel-$VERSION-tmp.zip ../arter97-kernel-$VERSION.zip
	rm arter97-kernel-$VERSION-tmp.zip
	cd ..
	ls -al arter97-kernel-$VERSION.zip
	rm kernelzip/boot.img
fi

if [ -e recovery.img ] ; then
	rm twrp-arter97-$VERSION.zip 2>/dev/null
	cp recovery.img recoveryzip/recovery.img
	cp recovery.img twrp-arter97-$VERSION.img
	cd recoveryzip/
	7z a -mx0 twrp-arter97-$VERSION-tmp.zip *
	zipalign -v 4 twrp-arter97-$VERSION-tmp.zip ../twrp-arter97-$VERSION.zip
	rm twrp-arter97-$VERSION-tmp.zip
	cd ..
	ls -al twrp-arter97-$VERSION.zip
	rm recoveryzip/recovery.img
fi

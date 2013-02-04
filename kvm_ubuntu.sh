#!/bin/bash

DIR="/mnt/md4"
BACKING_FILE="$DIR/precise-server-cloudimg-amd64-disk1.qcow2"

if [ ! -e "$BACKING_FILE" ]; then
	echo "Backing file $BACKING_FILE doesn't exist, exiting..."
	exit 1
fi

#rm -f $DIR/*.img

#pkill -f "kvm -drive"
#pkill -f "kvm -S"

for i in $(seq 1 150); do
	if [ -e $DIR/$i.img ]; then
		rm $DIR/$i.img
	fi
	qemu-img create -f qcow2 -b $BACKING_FILE $DIR/$i.img
done

for i in $(seq 1 150 ); do
	echo "booting instance $i ..."
#	kvm -drive file=$DIR/$i.img,if=virtio -boot c -m 512 -net nic -display vnc=:$i &
	#-device virtio-blk-pci,bus=pci.0,addr=0x4,drive=drive-virtio-disk0,id=virtio-disk0,bootindex=1  \
	#kvm \
	#-S \
	#-M pc-1.0 \
	#-enable-kvm \
	#-m 512 \
	#-drive file=$DIR/$i.img,if=none,id=drive-virtio-disk0,format=qcow2,cache=none \
	#-net nic \
	#-display vnc=:$i &
	kvm -drive if=virtio,file=$DIR/$i.img \
	-m 2048 \
	-boot a \
	-net nic \
	-net user \
	-nographic \
	-vnc :$i \
	-chardev file,id=charserial0,path=$DIR/$i.console.log \
	-device isa-serial,chardev=charserial0,id=serial0 \
	-chardev pty,id=charserial1 \
	-device isa-serial,chardev=charserial1,id=serial1 \
	-device virtio-balloon-pci,id=balloon0,bus=pci.0,addr=0x5 &
	echo "Sleeping for 10 seconds..."
	sleep 10
done

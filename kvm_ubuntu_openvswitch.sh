#!/bin/bash

DIR="/mnt/intel"
BACKING_FILE="$DIR/precise-server-cloudimg-amd64-disk1.qcow2"

if [ ! -e "$BACKING_FILE" ]; then
	echo "Backing file $BACKING_FILE doesn't exist, exiting..."
	exit 1
fi

#rm -f $DIR/*.img

#pkill -f "kvm -drive"
#pkill -f "kvm -S"

for i in $(seq 11 200); do
	if [ -e $DIR/$i.img ]; then
		rm $DIR/$i.img
	fi
	qemu-img create -f qcow2 -b $BACKING_FILE $DIR/$i.img
done

for i in $(seq 11 200 ); do
	echo "booting instance $i ..."
	# Generate random mac
	MAC=`(date; cat /proc/interrupts) | md5sum | sed -r 's/^(.{6}).*$/\1/; s/([0-9a-f]{2})/\1:/g; s/:$//;'`
	# 52... is the kvm allocation
	MAC=52:54:00:${MAC}
	echo "macaddr is $MAC"

	# Boot the instance...
	kvm -drive if=virtio,file=$DIR/$i.img \
	-m 512 \
	-boot a \
	-net nic,macaddr=${MAC} \
	-net tap,script=/sbin/ovs-ifup,downscript=/sbin/ovs-ifdown \
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

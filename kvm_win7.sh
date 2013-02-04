#!/bin/bash

DIR="/mnt/md4/win7"
BACKING_FILE="/mnt/md4/win7_base.img"

if [ ! -e "$BACKING_FILE" ]; then
	echo "Backing file $BACKING_FILE doesn't exist, exiting..."
	exit 1
fi

rm -f $DIR/*.img

#pkill -f "kvm -drive"
#pkill -f "kvm -S"

for i in $(seq 71 99 ); do
	if [ -e $DIR/$i.img ]; then
		rm $DIR/$i.img
	fi
	qemu-img create -f qcow2 -b $BACKING_FILE $DIR/$i.img
done

for i in $(seq 71 99 ); do
        echo "====> Starting a new instance $i..."
        # Remove the old backing file
        rm -f $DIR/win7-$i.qcow2

        # Create a new backing file that is a qcow2 snapshot of the original file
        qemu-img create -f qcow2 -b $BACKING_FILE $DIR/win7-$i.qcow2

        #-smp 2,sockets=2,cores=1,threads=1 \
        # Actually start the intstance
        /usr/bin/kvm \
        -M pc-1.0 \
        -enable-kvm \
        -m 4096 \
        -drive file=$DIR/win7-$i.qcow2,if=virtio \
        -boot d \
        -net nic,model=virtio \
        -net user \
        -nographic \
        -vnc :$i \
        -device virtio-balloon-pci,id=balloon0,bus=pci.0,addr=0x5 \
        -daemonize

        # Let's just sleep for a few seconds...
	echo "Sleeping for 240 seconds..."
	sleep 240
done

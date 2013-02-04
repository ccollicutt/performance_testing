#!/bin/bash

echo "Note that the write tests will destroy data on the drive!!!"
echo "Continue? y/n"
read CONTINUE

if [ "$CONTINUE" != "y" ]; then
	echo "Exiting..."
	exit 1
fi

exit 0

if [ -z "$1" ]; then
	echo "USAGE: $0 devicename"
	echo "eg. $0 fioa"
	exit 1
else
	DEVICE=$1
fi

if [ ! -e /dev/$DEVICE ]; then
	echo "/dev/$DEVICE does not exist, exiting..."
	exit 1
fi

NOW=$(date +"%Y_%m_%d_%H_%M_%S")

# Write IOPS test
echo "Running write IOPS test..."
fio --name=writeiops --filename=/dev/$DEVICE --direct=1 --rw=randwrite --bs=512 --numjobs=4 --iodepth=32 --direct=1 --iodepth_batch=16 --iodepth_batch_complete=16 --runtime=300 --ramp_time=5 --norandommap --time_based --ioengine=libaio --group_reporting > ./results/${DEVICE}_${NOW}_writeiops.out

# Write Bandwidth test
echo "Running write bandwidth test..."
fio --name=writebw --filename=/dev/$DEVICE --direct=1 --rw=randwrite --bs=1m --numjobs=4 --iodepth=32 --direct=1 --iodepth_batch=16 --iodepth_batch_complete=16 --runtime=300 --ramp_time=5 --norandommap --time_based --ioengine=libaio --group_reporting > ./results/${DEVICE}_${NOW}_writebw.out

# Read IOPS test
echo "Running read IOPS test..."
fio --name=readiops --filename=/dev/$DEVICE --direct=1 --rw=randwrite --bs=512 --numjobs=4 --iodepth=32 --direct=1 --iodepth_batch=16 --iodepth_batch_complete=16 --runtime=300 --ramp_time=5 --norandommap --time_based --ioengine=libaio --group_reporting > ./results/${DEVICE}_${NOW}_readiops.out

# Read Bandwidth test
echo "Running read bandwidth test..."
fio --name=readbw --filename=/dev/$DEVICE --direct=1 --rw=randread --bs=1m --numjobs=4 --iodepth=32 --direct=1 --iodepth_batch=16 --iodepth_batch_complete=16 --runtime=300 --ramp_time=5 --norandommap --time_based --ioengine=libaio --group_reporting > ./results/${DEVICE}_${NOW}_readbw.out


echo "Done!"

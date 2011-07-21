#!/bin/bash

count=0

while [ 1 ]
do
	STRESS=1 ./generate.csh || break
	count=$(($count + 1))
done

echo
echo "stress test ran successfully $count times before failing"


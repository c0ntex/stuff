#!/bin/bash
##
# chap heap analysis tool script to dump free's and malloc's so that they can be diff'd
# to compair the status of the heap between a running a clean (good) and dirty (bad) file
##

ulimit -c unlimited
export PATH=:./chap/build-chap:$PATH
export target=$1

if [ -z $1 ]; then
	echo "must pass target process as argument" ; exit 1
elif [ -z $(which chap) ] ; then
	echo "this script needs chap - https://github.com/vmware/chap - Go get it? [y/n] "
    read clone
    if [ $clone == "y" ] ; then
        git clone https://github.com/vmware/chap
        cd chap
		git submodule update --init --recursive
        mkdir build-chap
        cd build-chap
        cmake ../
	    make
	    cd ../../
    fi
fi

testcases=("clean" "dirty")
types=("free" "alloc")

for i in "${testcases[@]}"
do
	printf "Running against $i\n"
	if [[ $i -eq "clean" ]]; then
		$target ./$i &
		sleep 7 # let the file finish
		kill -11 $(pidof $target) 2>/dev/null
	else
		$target ./$i 2>/dev/null
	fi

	printf "Dumping free and alloc references..\n"; sleep 5
	script -c bash -c 'echo "show free" | chap ./core ; exit' $target-$i-free 2>&1 > /dev/null
	script -c bash -c 'echo "show used" | chap ./core ; exit' $target-$i-alloc 2>&1 > /dev/null
	fromdos $target-$i-* ; mv core $target-$i-core

done 2>/dev/null; printf "\n"

##
# Diff the files and get stats
##
for i in "${types[@]}"
do
	sdiff $target-clean-$i $target-dirty-$i >> $target-$i.sdiff
	freediffc=$(grep "<" $target-$i.sdiff | wc -l)
	freediffd=$(grep ">" $target-$i.sdiff | wc -l)
	printf "Stats on $i\n"
	echo "$i: clean->[$freediffc]"
	echo "$i: dirty->[$freediffd]"
done

rm *.symreqs 2>/dev/null

exit 0


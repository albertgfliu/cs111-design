#! /bin/bash

wd=.

#verify everything is working correctly
$wd/lab3-tester.pl

#create a huge file
echo "yes | head -n 9999999 > test/yes.txt"
yes | head -n 9999999 > test/yes.txt

#check contents of directory
echo "ls -l test"
ls -l test

#make it crash
echo "$wd/ioctl-nwrite 10"
$wd/ioctl-nwrite 10

#remove it, making test/yes.txt "disappear" silently
echo "rm test/yes.txt"
rm test/yes.txt

#check that it's gone
echo "ls -l test"
ls -l test

#uncrash it
echo "$wd/ioctl-nwrite -1"
$wd/ioctl-nwrite -1

#write a small file and see that we get -ENOSPC, no space left on device!
echo "yes | head -n 99999 > test/yes.txt"
yes | head -n 99999 > test/yes2.txt

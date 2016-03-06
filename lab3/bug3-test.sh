#! /bin/bash

wd=.

#make it crash asap
echo "$wd/ioctl-nwrite 0"
$wd/ioctl-nwrite 0

#create a file
echo "touch test/a.txt"
touch test/a.txt

#see if it worked (which it did not, since it cannot "find" it since it was never linked to linux inode)
echo "ls -l test"
ls -l test
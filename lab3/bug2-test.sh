#! /bin/bash

wd=.

#make it crash soon
echo "$wd/ioctl-nwrite 5"
$wd/ioctl-nwrite 5

#copy an image over
echo "cp test/pokercats.gif test/newpokercats.gif"
cp test/pokercats.gif test/newpokercats.gif
echo "ls -l test"
ls -l test

#uncrash it
echo "$wd/ioctl-nwrite -1"
$wd/ioctl-nwrite -1

#see that the image can't be read
echo "zgv test/newpokercats.gif"
zgv test/newpokercats.gif
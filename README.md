#CS 111 Winter 2016 Design (Lab 3)

The design project chosen for this lab is OSPFS Crash Testing. The description is as follows:

**OSPFS Crash Testing**

As we've discussed in class, file systems are expected to be robust: no matter when the computer crashes, a file system should leave stable storage correct (i.e., satisfying all four file system invariants), or at least sufficiently correct that no file system data is lost. Your OSPFS implementation is probably not robust!

This design problem asks you to design a mechanism to test file system robustness by "crashing" the OSPFS file system.

   *Test: Introduce a per-OSPFS variable called nwrites_to_crash. OSPFS users can set this variable by making a system call on an open OSPFS file (an ioctl). When this variable is -1 (the default), OSPFS should act as usual. If the variable is 0, then the file system has "crashed": every write to disk data should silently fail. That is, any time that your OSPFS code writes to disk, whether in a data block, a superblock, an inode block, or whatever, the write should be ignored. If the variable is GREATER than 0, then the variable should be decremented by 1 for every write to a different block. Thus, after nwrites_to_crash writes, the OSPFS will "crash".

   *Find bugs: Design a test program that demonstrates a bug with your OSPFS implementation. That is, your program should set nwrites_to_crash and then make a series of system calls -- writes, creates, links, unlinks, whatever -- so that after the "crash", the file system is left in an incorrect state. This will require that you understand incorrect states and figure out how to cause one. Demonstrate the problem by "uncrashing" the file system (setting nwrites_to_crash to -1), performing some more file system operations, and showing that the result is disaster (missing files, etc.).


What I did: added two new functions ospfs_ioctl and check_crashed

Functions that will silently fail:
ospfs_write
create_blank_direntry
ospfs_create
ospfs_link
ospfs_symlink

ACTUALLY NEEDS TO DECREMENT BY 1 FOR WRITE TO EACH DIFFERENT BLOCK. CURRENT IMPLEMENTATION MAY NOT BE CORRECT.
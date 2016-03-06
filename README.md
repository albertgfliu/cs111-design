#CS 111 Winter 2016 Design (Lab 3)

The design project chosen for this lab is OSPFS Crash Testing. The description is as follows:

**OSPFS Crash Testing**

As we've discussed in class, file systems are expected to be robust: no matter when the computer crashes, a file system should leave stable storage correct (i.e., satisfying all four file system invariants), or at least sufficiently correct that no file system data is lost. Your OSPFS implementation is probably not robust!

This design problem asks you to design a mechanism to test file system robustness by "crashing" the OSPFS file system.

   *Test: Introduce a per-OSPFS variable called nwrites_to_crash. OSPFS users can set this variable by making a system call on an open OSPFS file (an ioctl). When this variable is -1 (the default), OSPFS should act as usual. If the variable is 0, then the file system has "crashed": every write to disk data should silently fail. That is, any time that your OSPFS code writes to disk, whether in a data block, a superblock, an inode block, or whatever, the write should be ignored. If the variable is GREATER than 0, then the variable should be decremented by 1 for every write to a different block. Thus, after nwrites_to_crash writes, the OSPFS will "crash".

   *Find bugs: Design a test program that demonstrates a bug with your OSPFS implementation. That is, your program should set nwrites_to_crash and then make a series of system calls -- writes, creates, links, unlinks, whatever -- so that after the "crash", the file system is left in an incorrect state. This will require that you understand incorrect states and figure out how to cause one. Demonstrate the problem by "uncrashing" the file system (setting nwrites_to_crash to -1), performing some more file system operations, and showing that the result is disaster (missing files, etc.).

**Goals & Results (Test)**

	Goal 1: Introduce a per-OSPFS variable called nwrites_to_crash.

	Result 1: Inside ospfsmod.c, a variable nwrites_to_crash with type long is declared


	Goal 2: OSPFS users can set this variable by making a system call on an open OSPFS file (an ioctl).

	Result 2: A program named ioctl-nwrite is created through recursive make whenever make is ran in the lab3 folder, i.e. when we execute run-qemu and the make is ran in the lab3 folder inside qemu. ioctl-nwrite, when ran, first opens a file "test/foo", issues an ioctl with a predetermined OSPFS_NWRITE command argument (defined in ospfs.h and ioctl folder's main.c as 999), and then closes the file "test/foo". ioctl-nwrite was programmed so that by default, if no arguments are given to ioctl-nwrite, it will by default call ioctl with an argument of 10. We can specify any other numerical argument we want and the ioctl-nwrite program will set nwrites_to_crash to that. Inside ospfsmod.c, ospfs_ioctl was hooked to the ioctl system call in the ospfs_reg_file_ops struct. We set nwrites_to_crash if OSPFS_NWRITE was the command argument given by ioctl, otherwise we return -EINVAL: invalid argument.


	Goal 3: When this variable [nwrites_to_crash] is -1 (the default), OSPFS should act as usual. 

	Result 3: A function named check_crashed() was implemented. Everytime it is called, it returns the status of the file system and decrements nwrites_to_crash if it is positive. Thus, a return value of 0 corresponds to a crashed file system and any other number, i.e. -1 or any positive integer, corresponds to an uncrashed file system. nwrites_to_crash is by default initialized as -1, allowing OSPFS to behave as usual from the start. 


	Goal 4: If the variable is 0, then the file system has "crashed": every write to disk data should silently fail. That is, any time that your OSPFS code writes to disk, whether in a data block, a superblock, an inode block, or whatever, the write should be ignored.

	Result 4: Implement this now... report results back later.


	Goal 5: If the variable is GREATER than 0, then the variable should be decremented by 1 for every write to a different block. Thus, after nwrites_to_crash writes, the OSPFS will "crash".

	Result 5: This was implemented in check_crashed() as described in Result 3. We will only call check_crashed() when we wish to write to a block. When nwrites_to_crash is 1, check_crashed() will return 1, meaning that we can still write, but decrements it to 0 after returning 1. The next call to check_crashed() will then tell us that the file system is crashed by returning 0.


Results (Find bugs)

	



**Conclusion**

So what's the solution to all this? OSPFS Crash Testing shows that bad things can happen if we continue operations while the file system is crashed. We need some way to detect if our file system has crashed and how to reverse the crashed changes. Clearly, it is unrealistic in modern file systems that all writes "silently fail". File systems typically have some mechanism that return the number of bytes successfully written. If the file system has crashed on the software side, we should have some mechanism in place that guarantees that we receive the correct signal. Hardware signals and error correction modules attached to data modules such as RAM and disk can easily signal us if there is something wrong with writing to certain blocks in physical memory. File system journaling, where changes can be rewinded and writes are atomically made, assist in remedying and mitigating file system crashes.
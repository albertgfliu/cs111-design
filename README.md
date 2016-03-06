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

Result 4: Implement this now... report results back later. Find where blocks are DIRECTLY being modified, not where we call functions that modify blocks.

Did NOT add silent crashes to modifying the bitmap, i.e. allocate_block() and free_block(). We did not consider the bitmap a "block". They will not be called anyways during a crash, as add_block() and remove_block(), the only two functions that call allocate_block() and free_block(), will silently fail anyways.

Functions that were modified: ospfs_unlink() since it modifies od->ino and oi->oinlink, which are in directory and inode blocks respectively, add_block() and remove_block() since those modify data blocks. To have add_block() and remove_block() "silently" fail, the size member variable of the corresponding inode was still modified. This enables programs like cp believe that it succeeded.

Functions that do write but were not modified: change_size() since it does not directly modify any data blocks. It just calls helper functions add_block() and remove_block(), which do directly modify blocks. Those two will give the illusion to change_size() that change_size() executed successfully.

Functions that still need to be modified: ospfs_write, create_blank_direntry, ospfs_link, ospfs_create, ospfs_symlink


Goal 5: If the variable is GREATER than 0, then the variable should be decremented by 1 for every write to a different block. Thus, after nwrites_to_crash writes, the OSPFS will "crash".

Result 5: This was implemented in check_crashed() as described in Result 3. We will only call check_crashed() when we wish to write to a block. When nwrites_to_crash is 1, check_crashed() will return 1, meaning that we can still write, but decrements it to 0 after returning 1. The next call to check_crashed() will then tell us that the file system is crashed by returning 0.


**Results (Find bugs)**

Bug 1: OSPFS runs out of space before it should

Bug 1 description: Let us say we create a large file in OSPFS before any crashes. Afterwards, we decide to remove it while the file system is crashed. Of course, we believe that it should be removed successfully if no warnings are thrown. We then decide to create another large file, but then find that we run out of space before we thought we would! This happens when OSPFS does not free the bitmaps when we remove files.

Potential solution to Bug 1: Run a fixer at intervals to free bits in the bitmap corresponding to "orphaned" blocks that have nothing pointing to it.

How to test: 
	#write lots of blocks
	yes | head -n LOTSOFLINES > test/yes.txt
	#make it crash
	./ioctl-nwrite 10
	rm test/yes.txt
	#uncrash it
	./ioctl-nwrite -1
	#write a small file and see that we get -ENOSPC
	yes | head -n notsomanylines > test/yes.txt


Bug 2: Files are not copied successfully

Bug 2 description: OSPFS crashes in the middle of copying a large file over, resulting in the writes since the failure to "silently" fail without warning.

Potential solution to Bug 2: Have atomic writes that copy the entire file over after it's been guaranteed that there is no crash and it will work successfully. File system journaling will help with this.

How to test:
	#make it crash soon
	./ioctl-nwrite 5
	#copy an image over
	cp test/pokercats.gif test/newpokercats.gif
	ls -l test
	#uncrash it
	./ioctl-nwrite -1
	#see that the image can't be read
	zgv test/newpokercats.gif


Bug 3: Files can't be created

Bug 3 description: Files created after the file system has crashed don't show up.

Potential solution to Bug 3: As discussed previously, file system journaling will help with this. However, operations on that created file can't be done while crashed which tips off the user that something bad is happening.

How to test:
	#make it crash asap
	./ioctl-nwrite 0
	#create a file
	touch test/a.txt
	#see if it worked
	ls -l


**Conclusion**

So what's the solution to all this? OSPFS Crash Testing shows that bad things can happen if we continue operations while the file system is crashed. We need some way to detect if our file system has crashed and how to reverse the crashed changes. Clearly, it is unrealistic in modern file systems that all writes "silently fail". File systems typically have some mechanism that return the number of bytes successfully written. If the file system has crashed on the software side, we should have some mechanism in place that guarantees that we receive the correct signal. Hardware signals and error correction modules attached to data modules such as RAM and disk can easily signal us if there is something wrong with writing to certain blocks in physical memory. File system journaling, where changes can be rewinded and writes are atomically made, assist in remedying and mitigating file system crashes.
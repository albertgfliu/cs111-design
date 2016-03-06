#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <stdlib.h>

#define OSPFS_NWRITE 999

int main(int argc, char *argv[]){
	int fd, ioctl_val, nwrites;
	//default values
	nwrites = 10;

	//printf("trying to open %s\n", argv[1]); 
	fd = open("test/foo", O_NONBLOCK | O_CREAT);
	if(argc >= 2)
		nwrites = atoi(argv[1]);
	printf("trying to write value %d\n", nwrites);
	ioctl_val = ioctl(fd, OSPFS_NWRITE, (unsigned long)nwrites);
	if(ioctl_val == -1)
		printf("error on ioctl with error %s\n", strerror(errno));
	else
		printf("finished ioctl on a file, return value %d\n", ioctl_val);
	// printf("finished opening a file\n");
	// printf("closing a file\n");
	close(fd);
	// printf("closed a file\n");
}

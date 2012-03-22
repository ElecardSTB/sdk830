#include <stdio.h>


int main(int argc, char **argv )
{
	char *filename;
	FILE *image_fd;
	FILE *sum_fd;
	int sum = 0;
	int ch;
	char sumFilename[256];

	if(argc < 2)
	{
		printf("%s <filename>\n", argv[0]);
		return -1;
	}

	filename = argv[1];
	image_fd = fopen(filename, "rb");
	if(image_fd == NULL)
	{
		printf("Cant open file %s\n", filename);
		return -1;
	}

	while((ch = getc(image_fd)) != EOF)
	{
		sum = (sum >> 1) + ((sum & 1) << 15);
		sum += ch;
		sum &= 0xffff;
	}

	{
		sprintf(sumFilename, "%s.sum", filename);
		sum_fd = fopen(sumFilename, "w");
		fprintf(sum_fd, "%05d", sum);
		fclose(sum_fd);
	}

	fclose(image_fd);

	return 0;
}

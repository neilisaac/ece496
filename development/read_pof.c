/* 
 * read_pof.c - Created April 10, 2011
 * Read information in a POF file
 * Neil Isaac <neil@neilisaac.ca>
 */

#include "pof.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void sparse_hexdump(unsigned char *buf, int length, int cols)
{
	if (cols == 0) {
		printf(" [hex data omitted]\n");
		return;
	}

	int stride = 4 * cols;
	int enable = 0;
	for (int i = 0; i < length; i++) {
		// first digit of each line
		if (i % stride == 0) {
			for (int j = i; j < i + stride; j++) {
				if (buf[j] != 0 && buf[j] != 0xFF) {
					printf("0x%x: %02x", i, buf[i]);
					enable = 1;
					break;
				}
			}
		}
		
		// other digits on non-empty lines
		else if (enable) {
			// split 32bit sets
			if (i % 4 == 0)
				printf(" %02x", buf[i]);
			else
				printf("%02x", buf[i]);

			// end of line
			if (i % stride == stride - 1) {
				enable = 0;
				printf("\n");
			}
		}
	}

	if (length % stride)
		printf("\n");
}

int main(int argc, char *argv[])
{
	if (argc < 2) {
		printf("usage: %s <file.pof>\n", argv[0]);
		return 1;
	}

	int hexdump_cols = 0;
	if (argc >= 3 && strncmp(argv[2], "-d", 2) == 0)
		hexdump_cols = 8;
	
	struct pof_file *pof = pof_file_read(argv[1]);
	if (pof == NULL) {
		printf("failed to read pof file\n");
		return 1;
	}
	
	struct pof_packet *packet = pof->packets;
	while (packet != NULL) {
		switch (packet->tag) {
		case 1:
			printf("creator: %s\n", packet->data);
			break;
		case 2:
			printf("device: %s\n", packet->data);
			break;
		case 3:
			printf("comment: %s\n", packet->data);
			break;
		case 5:
			printf("security bit: %d\n", * (int *) packet->data);
			break;
		case 6:
			printf("logical data 16:\n");
			sparse_hexdump(packet->data, packet->length, hexdump_cols);
			printf("\n");
			break;
		case 7:
			printf("electrical data:\n");
			sparse_hexdump(packet->data, packet->length, hexdump_cols);
			break;
		case 8:
			printf("end of pof\n");
			break;
		case 10:
			printf("test vectors:\n");
			sparse_hexdump(packet->data, packet->length, hexdump_cols);
			break;
		case 14:
			printf("programmable elements: %d\n", * (int *) packet->data);
			break;
		case 17:
			printf("logical data 32:\n");
			sparse_hexdump(packet->data, packet->length, hexdump_cols);
			break;
		case 26:
			printf("someting interesting (26):\n");
			sparse_hexdump(packet->data, packet->length, hexdump_cols);
			break;
		default:
			printf("unknown tag: #%d\n", packet->tag);
		}
				
		packet = packet->next;
	}

	return 0;
}


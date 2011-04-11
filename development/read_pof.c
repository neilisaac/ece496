/* 
 * read_pof.c - Created April 10, 2011
 * Read information in a POF file
 * Neil Isaac <neil@neilisaac.ca>
 */

#include "pof.h"

#include <stdio.h>

int main(int argc, char *argv[])
{
	if (argc != 2) {
		printf("usage: %s <file.pof>\n", argv[0]);
		return 1;
	}
	
	struct pof_file *pof = pof_file_read(argv[1]);
	if (pof == NULL) {
		printf("failed to read pof file\n");
		return 1;
	}
	
	struct pof_packet *packet = pof->packets;
	while (packet != NULL) {
		printf("tag: %d len: %d data: %s\n", packet->tag,
				packet->length, packet->data);
				
		packet = packet->next;
	}

	return 0;
}


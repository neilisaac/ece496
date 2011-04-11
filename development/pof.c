/* 
 * pof.c - Created April 11, 2011
 * POF file reading/writing
 * Neil Isaac <neil@neilisaac.ca>
 */

#include "pof.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <arpa/inet.h>

static struct pof_packet *read_packet(FILE *file)
{
	struct pof_packet *packet = malloc(sizeof(*packet));

	if (fread(&packet->tag, 2, 1, file) != 1)
		goto READPACKET_FAIL;
	if (fread(&packet->length, 4, 1, file) != 1)
		goto READPACKET_FAIL;

	packet->data = malloc(packet->length);
	if (fread(packet->data, 1, packet->length, file) != packet->length)
		goto READPACKET_FAIL;

	return packet;

READPACKET_FAIL:
	printf("read_packet encountered an error\n");
	free(packet);
	return NULL;
}

struct pof_file *pof_file_init()
{
	struct pof_file *pof = malloc(sizeof(*pof));
	pof->tool = "unknown tool";
	pof->device = "unknown device";
	pof->comment = "no comment";
	pof->security_bit = 0;
	pof->data = NULL;
	pof->num_packets = 0;
	pof->packets = NULL;
	return pof;
}

struct pof_file *pof_file_read(char *filename)
{
	// open file
	FILE *file = fopen(filename, "r");
	if (!file) {
		printf("couldn't open file: %s\n", filename);
		return NULL;
	}
	
	// read first 4 bytes as file id (POF)
	int magic = * (int*) "POF\0";
	int header;
	if (fread(&header, 4, 1, file) != 1)
		goto READFILE_FAIL;
	if (header != magic) {
		printf("file %s doesn't seem to be a POF file\n", filename);
		printf("magic: %x  file: %x\n", magic, header);
		return NULL;
	}
	
	// ignore next 8 bytes
	fseek(file, 8, SEEK_CUR);
	
	// read packets from file
	struct pof_file *pof = pof_file_init();
	struct pof_packet *prev = NULL;
	while (!feof(file)) {
		// read 1 packet
		struct pof_packet *packet = read_packet(file);
		if (packet == NULL) goto READFILE_FAIL;
		pof->num_packets++;
		
		// add to linked list
		if (prev) prev->next = packet;
		else      pof->packets = packet;
		
		// check for terminator packet
		if (packet->tag == 8)
			break;
		
		prev = packet;
		prev->next = NULL;
	}

	return pof;

READFILE_FAIL:
	printf("pof_file_read failed to read %s\n", filename);
	return NULL;
}


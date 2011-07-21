/* 
 * pof.h - Created April 11, 2011
 * POF file reading/writing
 * Neil Isaac <neil@neilisaac.ca>
 */

#ifndef POF_H_
#define POF_H_

struct pof_file;
struct pof_packet;
struct pof_data;

struct pof_file *pof_file_read(char *);

struct pof_file {
	char *tool;
	char *device;
	char *comment;
	int security_bit;
	struct pof_data *data;
	unsigned int num_packets;
	struct pof_packet *packets;
};

struct pof_packet {
	unsigned short tag;
	unsigned int length;
	unsigned char *data;
	struct pof_packet *next;
};

struct pof_data {
	int dummy;
};

#endif


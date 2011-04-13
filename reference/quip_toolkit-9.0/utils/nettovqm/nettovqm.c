/* nettovqm [ -a architecture ] [ -k lutsize ] designname
 *
 * This program reads a file called designname.net and produces a file
 * called designname.vqm.  The input file must be a VPR .net format input
 * file for an VPR architecture with the following attributes:
 *
 * 1) one BLE per CLB
 * 2) k input LUT (default k=4)
 * 3) each BLE has these pins, in this order:
 *    a) the k LUT inputs
 *    b) one output
 *    c) one clock input
 * 4) each CLB has the same number of pins as the BLE, in the same order as
 *    the BLE.
 *
 * The output file will be a version of the input netlist in Altera's .vqm
 * format.  You should be able to read the .vqm file into Quartus II.
 *
 * The optional -a flag specifies the Altera architecture that you are
 * targeting.  Each target has a slightly different .vqm file format.
 * The legal architectures are "Stratix" and "Cyclone".  Other Altera
 * architectures should be easy to add to this program.  The default
 * architecture is "Stratix".
 *
 * Copyright (c) 2002 Altera Corporation. All rights reserved.  Altera Proprietary.
 * Please do not change the following 3 lines of comments!
 * Altera products and services are protected under numerous U.S. and foreign patents, 
 * maskwork rights, copyrights and other intellectual property laws.  Altera assumes no 
 * responsibility or liability arising out of the application or use of this information 
 * and code. This notice must be retained and reprinted on any copies of this information 
 * and code that are permitted to be made."
 *
 *****************************************************************************/

#ifndef GCC_PEDANTIC_WARNINGS
static char *Version = "$Header: //acds/rel/9.0/quartus/devices/tpt/nettovqm.c#1 $";
#endif

#include <stdio.h>
#include <stdlib.h>
#include <string.h>


/* The set of architectures that this program accepts */
typedef enum {
   ARCH_STRATIX = 0,
   ARCH_CYCLONE,
   ARCH_MAXII,
   NUM_ARCHITECTURES
   } t_architecture;


#define DEFAULT_ARCHITECTURE ARCH_STRATIX

#define DEFAULT_LUTSIZE      (4)

/* The maximum line length we'll accept in a .net file */
#define MAX_LINE_SIZE        (16 * 1024)

/* The maximum number of characters in a block name */
#define MAX_NAME_LENGTH      (16 * 1024)

/* The maximum number of tokens on each line */
#define MAX_TOKENS_PER_LINE  (100)


/* The type of blocks we can read from a .net file */
typedef enum {
   BLOCK_INPUT = 0,
   BLOCK_OUTPUT,
   BLOCK_LCELL,
   NUM_BLOCK_TYPES
   } t_block_type;


/* A link list entry that holds a string */
typedef struct s_namelist {
   char *name;
   struct s_namelist *next;
   } t_namelist;


/* A simple hash table type */
typedef struct {
   int size;
   t_namelist *lists;   /* [0..size-1] */
   } t_hashtable;

/* A prime number used in the hash tables */
#define HASH_SIZE	4093


/* The names of the input and output files */
static char *inputfilename, *outputfilename;


/* The design name (without any .net extension) */
static char *designname;


/* The Altera architecture that we are generating the vqm netlist for */
static t_architecture arch;


/* The number of inputs on each LUT */
static int lut_size;


/* The line number we just read in the input .net file */
static int input_line_number;


/* Hash tables to hold the names of all of the nets, all of the circuit inputs
 * and all of the circuit outputs.
 */
static t_hashtable net_hash, inputs_hash, outputs_hash;


/* Declarations of the routines in this file */

static void usage(void);
static void parse_args(int argc, char *argv[]);
static void alloc_and_load_data(void);
static void free_memory(void);
static void convert_netfile_to_vqmfile(FILE *infile, FILE *outfile);
static void get_nonblank_line(FILE *infile, char *buf);
static int line_not_blank(char *buf);
static char *my_malloc(int nbytes);
static void my_free(void *ptr);
static char *my_calloc(int n, size_t size);
static void get_net_names_from_net_file(FILE *infile);
static void convert_one_block(FILE *infile, FILE *outfile);
static void parse_one_block(FILE *infile,
                              FILE *outfile,
                              int collect_net_names);
static void get_block_type_line(FILE *infile,
                                  int *blocktype_ptr,
                                  char **blockname_ptr);
static void get_pin_list_line(FILE *infile,
                                char ***pinlist_ptr,
                                int *num_pins_ptr);
static void get_subblock_line(FILE *infile,
                                char **subblock_name_ptr);
static void get_tokens(FILE *infile, char ***tokens_ptr, int *num_tokens_ptr);
static void get_nonblank_line(FILE *infile, char *buf);
static int line_not_blank(char *buf);
static void free_pinlist(char **pinlist, int num_pins);
static void insert_names_in_hash(t_hashtable *table,
                                   char **pinlist,
                                   int num_pins);
static void insert_name_in_hash(t_hashtable *table, char *name);
static int is_name_in_hash(t_hashtable *table, char *name);
static void insert_name_in_list(char *name, t_namelist *list);
static int is_name_in_list(char *name, t_namelist *list);
static int get_hash_value(char *string, int table_size);
static void free_hash_table(t_hashtable *table);
static void fatal(char *message);
static void print_list_of_module_ios(FILE *outfile);
static int print_comma_separated_list(FILE *outfile,
                                         t_hashtable *table,
                                         int print_comma_first);
static void print_io_declarations(FILE *outfile);
static void print_declarations(FILE *outfile,
                                 char *type,
                                 t_hashtable *table);
static void print_declaration(FILE *outfile,
                                char *type,
                                char *name);
static void print_internal_net_declarations(FILE *outfile);
static void vqm_print_input(FILE *outfile,
                              char *block_name,
                              char **pinlist,
                              int num_pins);
static void vqm_print_output(FILE *outfile,
                              char *block_name,
                              char **pinlist,
                              int num_pins);
static void vqm_print_lcell(FILE *outfile,
                              char *block_name,
                              char **pinlist,
                              int num_pins);
static char *vqm_name(char *name);
static char *vqm_internal_net_name(char *name);
static char *replace_funny_characters(char *name);
static int is_legal_verilog_name(char *name);
static char *get_architecture_prefix(void);




int main(int argc, char *argv[]) {

   FILE *infile, *outfile;

   parse_args(argc, argv);

   alloc_and_load_data();

   if((infile = fopen(inputfilename, "r")) == (FILE *) NULL) {
      fprintf(stderr, "nettovqm: can't open input file: ");
      perror(inputfilename);
      exit(1);
   }

   if((outfile = fopen(outputfilename, "w")) == (FILE *) NULL) {
      fprintf(stderr, "nettovqm: can't open output file: ");
      perror(outputfilename);
      exit(1);
   }

   convert_netfile_to_vqmfile(infile, outfile);

   free_memory();

   fclose(infile);
   fclose(outfile);

   exit(0);
}


static void parse_args(int argc, char *argv[]) {

   /* Look at the arguments to the program.  Parse them and store them.
    * Complain and die if they don't make sense.
    */

   int len;

   /* Set any default values. */

   arch = DEFAULT_ARCHITECTURE;
   lut_size = DEFAULT_LUTSIZE;

   while((argc > 1) && (argv[1][0] == '-')) {

      if(!strcmp(argv[1], "-a")) {
         if((argc >= 3) && !strcasecmp(argv[2], "Stratix")) {
            arch = ARCH_STRATIX;
         }
         else if((argc >= 3) && !strcasecmp(argv[2], "Cyclone")) {
            arch = ARCH_CYCLONE;
         }
         else if((argc >= 3) && !strcasecmp(argv[2], "MaxII")) {
            arch = ARCH_MAXII;
         }
         else {
            usage();
         }
         argc -= 2;
         argv += 2;
      }
 
      else if(!strcmp(argv[1], "-k")) {
         if(argc >= 3) {
            lut_size = atoi(argv[2]);
            if((lut_size < 1) || (lut_size > 100)) {
               usage();
            }
         }
         else {
            usage();
         }
         argc -= 2;
         argv += 2;
      }

      else {
         /* Don't understand this flag */
         usage();
      }
   }

   if(argc != 2) {
      usage();
   }

   designname = argv[1];

   /* If the user added .net to the end of the designname, take it off */

   len = strlen(designname);

   if(len > strlen(".net")) {
      if(!strcmp(&designname[len - strlen(".net")], ".net")) {
         designname[len - strlen(".net")] = '\0';
      }
   }
}


static void usage(void) {

   /* Print a message explaining how to use the program and exit */

   fprintf(stderr, "usage: nettovqm [ -a architecture ] [ -k lutsize ] designname\n");
   exit(1);
}


static void alloc_and_load_data(void) {

   /* Allocate and load up the global data structures */

   int nbytes;

   nbytes = strlen(designname) + strlen(".net") + 1;
   inputfilename = (char *) my_malloc(nbytes);
   sprintf(inputfilename, "%s.net", designname);

   nbytes = strlen(designname) + strlen(".vqm") + 1;
   outputfilename = (char *) my_malloc(nbytes);
   sprintf(outputfilename, "%s.vqm", designname);

   net_hash.size = HASH_SIZE;
   net_hash.lists = (t_namelist *) my_calloc(HASH_SIZE, sizeof(t_namelist));

   inputs_hash.size = HASH_SIZE;
   inputs_hash.lists = (t_namelist *) my_calloc(HASH_SIZE, sizeof(t_namelist));

   outputs_hash.size = HASH_SIZE;
   outputs_hash.lists = (t_namelist *) my_calloc(HASH_SIZE, sizeof(t_namelist));
}


static void free_memory(void) {

   /* Free the memory that was allocated by alloc_and_load_data() */

   my_free(inputfilename);
   inputfilename = (char *) NULL;

   my_free(outputfilename);
   outputfilename = (char *) NULL;

   free_hash_table(&net_hash);
   free_hash_table(&inputs_hash);
   free_hash_table(&outputs_hash);
}


static char *my_malloc(int nbytes) {

   /* Call malloc.  If it fails, print a message and die */

   char *result;

   result = (char *) malloc(nbytes);

   if(result == (char *) NULL) {
      fprintf(stderr, "nettovqm: can't allocate memory\n");
      exit(1);
   }

   return(result);
}



static void my_free(void *ptr) {

   /* Call free if this ptr is not NULL */

   if(ptr) {
      free(ptr);
   }
}


static char *my_calloc(int n, size_t size) {

   /* Call calloc.  If it fails, print a message and die */

   char *result;

   result = (char *) calloc(n, size);

   if(result == (char *) NULL) {
      fprintf(stderr, "nettovqm: can't allocate memory\n");
      exit(1);
   }

   return(result);
}


static void convert_netfile_to_vqmfile(FILE *infile, FILE *outfile) {

   /* Read a netlist from infile.  Write the equivalent netlist in vqm
    * format to outfile.
    */

   fprintf(outfile, "module %s (\n", vqm_name(designname));

   input_line_number = 0;

   get_net_names_from_net_file(infile);

   rewind(infile);
   input_line_number = 0;

   print_list_of_module_ios(outfile);

   fprintf(outfile, ");\n");

   print_io_declarations(outfile);
   print_internal_net_declarations(outfile);

   while(1) {
      convert_one_block(infile, outfile);

      if(feof(infile)) {
         break;
      }
   }

   fprintf(outfile, "endmodule\n");
}



static void get_net_names_from_net_file(FILE *infile) {

   /* Parse the entire input .net file, and make up lists of all the signals,
    * all the inputs and all the outputs in the circuit.
    */

   int collect_net_names = 1;

   while(1) {
      parse_one_block(infile, (FILE *) NULL, collect_net_names);

      if(feof(infile)) {
         break;
      }
   }
}



static void convert_one_block(FILE *infile, FILE *outfile) {

   /* Parse one block from the input file, and write the vqm version of
    * the block to the outfile.
    */

   int collect_net_names = 0;

   parse_one_block(infile, outfile, collect_net_names);
}



static void parse_one_block(FILE *infile,
                              FILE *outfile,
                              int collect_net_names) {

   /* Read one block from the input file.  If outfile is not NULL, write the
    * vqm version of the block to the outfile.  If collect_net_names is true,
    * add each new netname to the netnames list, each new input net to the
    * input_nets list and each new output net to the output_nets list.
    */

   char *block_name;
   int num_pins, num_legal_pins;
   int block_type;
   char **pinlist;

   get_block_type_line(infile, &block_type, &block_name);

   if(feof(infile)) {
      return;
   }

   get_pin_list_line(infile, &pinlist, &num_pins);

   /* Check for a legal number of pins */
   switch(block_type) {

   case BLOCK_INPUT :
      num_legal_pins = 1;
      break;

   case BLOCK_OUTPUT :
      num_legal_pins = 1;
      break;

   case BLOCK_LCELL :
      num_legal_pins = lut_size + 2;
      break;

   default :
      num_legal_pins = -1;
      break;
   }

   if(num_pins != num_legal_pins) {
      fatal("illegal number of pins on block");
   }

   if(collect_net_names) {
      insert_names_in_hash(&net_hash, pinlist, num_pins);

      switch(block_type) {

      case BLOCK_INPUT :
         insert_names_in_hash(&inputs_hash, pinlist, num_pins);
         break;

      case BLOCK_OUTPUT :
         insert_names_in_hash(&outputs_hash, pinlist, num_pins);
         break;

      default :
         break;
      }
   }

   if(block_type == BLOCK_LCELL) {
      get_subblock_line(infile, &block_name);
   }

   if(outfile != NULL) {
      switch(block_type) {
   
      case BLOCK_INPUT :
         vqm_print_input(outfile, block_name, pinlist, num_pins);
         break;
   
      case BLOCK_OUTPUT :
         vqm_print_output(outfile, block_name, pinlist, num_pins);
         break;
   
      case BLOCK_LCELL :
         vqm_print_lcell(outfile, block_name, pinlist, num_pins);
   
      default :
         break;
      }
   }

   free_pinlist(pinlist, num_pins);
}



static void get_block_type_line(FILE *infile,
                                  int *blocktype_ptr,
                                  char **blockname_ptr) {

   /* Find the next block type line in the .net file.  It should look like
    * one of:
    *    .input name
    *    .output name
    *    .clb name
    *
    * Ignore .global lines.  Complain about anything else.
    * Return a pointer to static storage.  The contents will be over-written
    * on the next call to this function.
    */

   static char blockname[MAX_NAME_LENGTH];
   char **tokens;
   int num_tokens;

   *blocktype_ptr = -1;
   *blockname_ptr = blockname;
   blockname[0] = '\0';

   while(1) {
      get_tokens(infile, &tokens, &num_tokens);

      if(feof(infile)) {
         return;
      }

      /* Skip over .global lines and ignore them */
      if(!strcasecmp(tokens[0], ".global")) {
         continue;
      }

      if(!strcasecmp(tokens[0], ".input")) {
         *blocktype_ptr = BLOCK_INPUT;
      }
      else if(!strcasecmp(tokens[0], ".output")) {
         *blocktype_ptr = BLOCK_OUTPUT;
      }
      else if(!strcasecmp(tokens[0], ".clb")) {
         *blocktype_ptr = BLOCK_LCELL;
      }
      else {
         fatal("do not recognize this line");
      }

      break;
   }

   if(num_tokens != 2) {
      fatal("illegal number of tokens on line");
   }

   strncpy(blockname, tokens[1], MAX_NAME_LENGTH-1);
   blockname[MAX_NAME_LENGTH-1] = '\0';
}




static void get_pin_list_line(FILE *infile,
                                char ***pinlist_ptr,
                                int *num_pins_ptr) {

   /* The next line should be a pinlist line.  It should look like:
    *   pinlist: p1 p2 p3 ...
    * Allocate memory for the list of pins.  The caller must free this memory.
    */

   char **tokens, **pinlist;
   int num_tokens, num_pins, itoken;

   *num_pins_ptr = 0;

   get_tokens(infile, &tokens, &num_tokens);

   if(feof(infile)) {
      return;
   }

   if((num_tokens == 0) || strcasecmp(tokens[0], "pinlist:")) {
      fatal("expecting pinlist: line");
   }

   num_pins = num_tokens - 1;
   *num_pins_ptr = num_pins;

   pinlist = (char **) my_malloc(num_pins * sizeof(char *));
   *pinlist_ptr = pinlist;

   for(itoken = 1; itoken < num_tokens; itoken++) {
      pinlist[itoken - 1] = strdup(tokens[itoken]);
   }
}



static void get_subblock_line(FILE *infile,
                                char **subblock_name_ptr) {

   /* The next line should be a subblock line.  Check it to make sure that
    * all of the pins are connected one-to-one to the CLB pins, and return
    * the subblock_name.  The subblock_name will be overwritten the next
    * time this routine is called, so save it if you need it.
    */

   static char subblock_name[MAX_NAME_LENGTH];
   char **tokens;
   int num_tokens, itoken;
   
   *subblock_name_ptr = subblock_name;
   subblock_name[0] = '\0';

   get_tokens(infile, &tokens, &num_tokens);

   if(feof(infile)) {
      return;
   }

   if((num_tokens == 0) || strcasecmp(tokens[0], "subblock:")) {
      fatal("expecting subblock: line");
   }

   if(num_tokens != (lut_size + 2 + 2)) {
      fatal("illegal number of tokens on subblock line");
   }

   strncpy(subblock_name, tokens[1], MAX_NAME_LENGTH-1);
   subblock_name[MAX_NAME_LENGTH-1] = '\0';

   for(itoken = 2; itoken < num_tokens; itoken++) {
      if(strcasecmp(tokens[itoken], "open")) {
         if(atoi(tokens[itoken]) != itoken-2) {
            fatal("BLE pins must be directly connected to CBE pins");
         }
      }
   }
}




static void get_tokens(FILE *infile, char ***tokens_ptr, int *num_tokens_ptr) {

   /* Find a non-blank line.  Split it up into an array of character string
    * tokens.  Ignore anything after a '#' comment character.
    * The next call to this routine will destroy the array of tokens, so
    * copy anything you want to save.
    */

   int num_tokens, was_blank;
   static char buf[MAX_LINE_SIZE];
   static char *tokens[MAX_TOKENS_PER_LINE];
   char *cp;

   num_tokens = 0;

   get_nonblank_line(infile, buf);

   if(feof(infile)) {
      return;
   }

   was_blank = 1;
   cp = buf;

   while(1) {
      if(*cp == '\0') {
         break;
      }

      if(*cp != ' ' && *cp != '\t' && *cp != '\n' && *cp != '\r') {
         if(was_blank) {
            if(*cp == '#') {
               /* The rest of the line is a comment */
               break;
            }

            tokens[num_tokens] = cp;
            num_tokens++;
         }
         was_blank = 0;
      }

      else {
         was_blank = 1;
         *cp = '\0';
      }

      cp++;
   }

   *num_tokens_ptr = num_tokens;
   *tokens_ptr = tokens;
}
      


static void get_nonblank_line(FILE *infile, char *buf) {

   /* Read a line from infile into buf.  Skip blank lines and comment lines.
    * If you hit the end of file, just return.
    */

   buf[0] = '\0';

   while(1) {
      fgets(buf, MAX_LINE_SIZE, infile);
   
      if(ferror(infile)) {
         fprintf(stderr, "nettovqm: error in reading input file:");
         perror(inputfilename);
         exit(1);
      }

      if(feof(infile)) {
         return;
      }

      input_line_number++;

      if(line_not_blank(buf)) {
         break;
      }
   }
}



static int line_not_blank(char *buf) {

   /* Return 1 if this line of text has tokens on it.  Return 0 if
    * it is blank, or just has a comment on it ("#" followed by anything).
    */

   int len, i;

   len = strlen(buf);

   for(i=0; i<len; i++) {

      if(buf[i] == '#') {

         /* This line just contains a comment */

         return(0);
      }

      if(buf[i] != ' ' && buf[i] != '\t' && buf[i] != '\n' && buf[i] != '\r') {

         /* We've found something interesting */

         return(1);
      }
   }

   return(0);
}



static void free_pinlist(char **pinlist, int num_pins) {

   /* Free this list of names, along with the names */

   int ipin;

   for(ipin = 0; ipin < num_pins; ipin++) {
      my_free(pinlist[ipin]);
      pinlist[ipin] = (char *) NULL;
   }

   my_free(pinlist);
}



static void insert_names_in_hash(t_hashtable *table,
                                   char **pinlist,
                                   int num_pins) {

   /* Insert the given array of names into the hash table */

   int ipin;

   for(ipin = 0; ipin < num_pins; ipin++) {
      insert_name_in_hash(table, pinlist[ipin]);
   }
}



static void insert_name_in_hash(t_hashtable *table, char *name) {

   /* Insert the given name into the hash table */

   int hash_value;

   if(!strcasecmp(name, "open")) {
      /* Ignore open pins */
      return;
   }

   hash_value = get_hash_value(name, table->size);

   insert_name_in_list(name, &table->lists[hash_value]);
}



static int is_name_in_hash(t_hashtable *table, char *name) {

   /* Return 1 if this name is found in this hash table */


   int hash_value;

   hash_value = get_hash_value(name, table->size);

   return(is_name_in_list(name, &table->lists[hash_value]));
}




static void insert_name_in_list(char *name, t_namelist *list) {

   /* Look for name in this list.  If it isn't there, add it */

   while(1) {
      if(list->name == (char *) NULL) {
         /* We've hit the end of the list.  Add the name to the list. */
         list->name = strdup(name);
         return;
      }

      if(!strcmp(list->name, name)) {
         /* The name is already in the list */
         return;
      }

      if(list->next == (t_namelist *) NULL) {
         list->next = (t_namelist *) my_calloc(1, sizeof(t_namelist));
      }

      list = list->next;
   }
}




static int is_name_in_list(char *name, t_namelist *list) {

   /* Look for name in this list.  Return 1 if it is there */

   while(1) {
      if(list->name == (char *) NULL) {
         return(0);
      }

      if(!strcmp(list->name, name)) {
         /* The name is already in the list */
         return(1);
      }

      if(list->next == (t_namelist *) NULL) {
         return(0);
      }

      list = list->next;
   }
}



static int get_hash_value(char *string, int table_size) {

   /* Make up a hash value from the contents of string */

   unsigned int result, imult;

   result = 0;
   imult = 1;

   while(*string) {
      result += imult * ((unsigned int) *string);
      imult *= 7;
      string++;
   }

   return(result % table_size);
}



static void free_hash_table(t_hashtable *table) {

   /* Free a hash table */

   int ientry;
   t_namelist *nlp, *nlp2;

   for(ientry = 0; ientry < table->size; ientry++) {

      nlp = &table->lists[ientry];
      my_free(nlp->name);
      nlp->name = (char *) NULL;
      nlp = nlp->next;

      while(nlp) {
         nlp2 = nlp->next;
         nlp->next = (t_namelist *) NULL;

         my_free(nlp->name);
         nlp->name = (char *) NULL;

         my_free(nlp);
         nlp = nlp2;
      }
   }

   my_free(table->lists);
   table->lists = (t_namelist *) NULL;
}



static void fatal(char *message) {

   /* Print this error message on the stderr and exit */

   fprintf(stderr, "nettovqm: fatal error on line %d: %s\n", input_line_number,
                   message);
   exit(1);
}



static void print_list_of_module_ios(FILE *outfile) {

   /* Print a comma separated list of the I/O pins on the design */

   int printed_something, print_comma_first;

   print_comma_first = 0;
   printed_something = print_comma_separated_list(outfile,
                                                    &inputs_hash,
                                                    print_comma_first);

   print_comma_first = printed_something;
   printed_something = print_comma_separated_list(outfile,
                                                    &outputs_hash,
                                                    print_comma_first);
}


static int print_comma_separated_list(FILE *outfile,
                                         t_hashtable *table,
                                         int print_comma_first) {

   /* Print all of the names in the table in a comma separated list.  Return
    * 1 if you printed anything.
    */

   t_namelist *nl;
   int ientry;

   for(ientry = 0; ientry < table->size; ientry++) {
      nl = &table->lists[ientry];

      while(nl) {
         if(nl->name != (char *) NULL) {
            if(print_comma_first) {
               fprintf(outfile, ",\n");
            }
            fprintf(outfile, "\t%s", vqm_name(nl->name));
            print_comma_first = 1;
    
            if(ferror(outfile)) {
               fprintf(stderr, "nettovqm: error in writing output file:");
               perror(outputfilename);
               exit(1);
            }
         }

         nl = nl->next;
      }
   }

   return(print_comma_first);
}



static void print_io_declarations(FILE *outfile) {

   /* Print the declarations of inputs and outputs */

   print_declarations(outfile, "input", &inputs_hash);
   print_declarations(outfile, "output", &outputs_hash);
}



static void print_declarations(FILE *outfile,
                                 char *type,
                                 t_hashtable *table) {

   /* Declare each entry in the hashtable. */

   t_namelist *nl;
   int ientry;

   for(ientry = 0; ientry < table->size; ientry++) {
      nl = &table->lists[ientry];

      while(nl) {
         if(nl->name != (char *) NULL) {
            print_declaration(outfile, type, nl->name);
         }

         nl = nl->next;
      }
   }
}




static void print_declaration(FILE *outfile,
                                char *type,
                                char *name) {

   /* Declare this variable */

   fprintf(outfile, "%s %s;\n", type, vqm_name(name));

   if(ferror(outfile)) {
      fprintf(stderr, "nettovqm: error in writing output file:");
      perror(outputfilename);
      exit(1);
   }
}



static char *vqm_name(char *name) {

   /* Signal names in the vqm file must be legal Verilog names.  If they
    * aren't, we have to put a \ before them, and a blank after them.
    * The memory in this routine will be overwritten the next time it
    * is called, so save it if necessary.
    */

   static char buf[MAX_NAME_LENGTH];

   if(is_legal_verilog_name(name)) {
      return(name);
   }

   sprintf(buf, "\\%s ", replace_funny_characters(name));
   return(buf);
}



static char *replace_funny_characters(char *name) {

   /* Quartus 3.0 hates certain characters in variable names.  This appears
    * to be fixed in the next release.  In the meantime, replace any
    * characters that it complains about.
    * The memory in this routine will be overwritten the next time it
    * is called, so save it if necessary.
    */

   static char buf[MAX_NAME_LENGTH];
   char *cp, *bufcp;

   buf[0] = '\0';
   bufcp = buf;

   for(cp = name; *cp; cp++) {

      switch(*cp) {

      case '[' :
         strcat(buf, "_LB_");
         bufcp += 4;
         break;

      case ']' :
         strcat(buf, "_RB_");
         bufcp += 4;
         break;

      default :
         *bufcp = *cp;
         bufcp++;
         *bufcp = '\0';
         break;
      }
   }

   return(buf);
}



static char *vqm_internal_net_name(char *name) {

   /* .net format allows the names of primary inputs and outputs to be
    * used as nets inside the circuit.  Vqm format doesn't.  Check to
    * see if this matches the name of an input or an output to the circuit,
    * and modify the name if so.
    * The memory in this routine will be overwritten the next time it
    * is called, so save it if necessary.
    */

   static char buf[MAX_NAME_LENGTH];

   if(!is_name_in_hash(&inputs_hash, name)
           && !is_name_in_hash(&outputs_hash, name)) {
      return(vqm_name(name));
   }

   sprintf(buf, "\\%s~internal ", replace_funny_characters(name));
   return(buf);
}


static int is_legal_verilog_name(char *name) {

   /* Would this be a legal verilog signal name ?  It apparently has to
    * be of the form [a-zA-Z_][a-zA-Z_0-9$]*.  There may be other rules
    * as well.
    */

   char *cp;
   int legal = 0;

   cp = name;

   if((*cp >= 'a') && (*cp <= 'z')) {
      legal = 1;
   }
   else if((*cp >= 'A') && (*cp <= 'Z')) {
      legal = 1;
   }
   else if(*cp == '_') {
      legal = 1;
   }

   if(!legal) {
      return(0);
   }

   cp++;

   while(*cp) {
      legal = 0;
      if((*cp >= 'a') && (*cp <= 'z')) {
         legal = 1;
      }
      else if((*cp >= 'A') && (*cp <= 'Z')) {
         legal = 1;
      }
      else if((*cp >= '0') && (*cp <= '9')) {
         legal = 1;
      }
      else if((*cp == '_') || (*cp == '$')) {
         legal = 1;
      }

      if(!legal) {
         return(0);
      }

      cp++;
   }

   return(1);
}
      



static void print_internal_net_declarations(FILE *outfile) {

   /* Declare each entry in the nets hashtable that isn't an input or an
    * output.
    */

   t_namelist *nl;
   int ientry;

   for(ientry = 0; ientry < net_hash.size; ientry++) {
      nl = &net_hash.lists[ientry];

      while(nl) {
         if(nl->name != (char *) NULL) {
            if(!is_name_in_hash(&inputs_hash, nl->name)
                    && !is_name_in_hash(&outputs_hash, nl->name)) {
               print_declaration(outfile, "wire", nl->name);
            }
         }

         nl = nl->next;
      }
   }
}



static void vqm_print_input(FILE *outfile,
                              char *block_name,
                              char **pinlist,
                              int num_pins) {

   /* Print an input cell to the vqm file */

   fprintf(outfile, "\n%s_io \\%s~I (\n",
                    get_architecture_prefix(),
                    replace_funny_characters(block_name));

   fprintf(outfile, "\t.padio(%s),\n", vqm_name(pinlist[0]));
   fprintf(outfile, "\t.combout(%s));\n", vqm_internal_net_name(pinlist[0]));
   fprintf(outfile, "defparam \\%s~I .operation_mode = \"input\";\n", 
                    replace_funny_characters(block_name));
}



static void vqm_print_output(FILE *outfile,
                              char *block_name,
                              char **pinlist,
                              int num_pins) {

   /* Print an output cell to the vqm file */

   fprintf(outfile, "\n%s_io \\%s~I (\n",
                    get_architecture_prefix(),
                    replace_funny_characters(block_name));

   fprintf(outfile, "\t.padio(%s),\n", vqm_name(pinlist[0]));
   fprintf(outfile, "\t.datain(%s));\n", vqm_internal_net_name(pinlist[0]));
   fprintf(outfile, "defparam \\%s~I .operation_mode = \"output\";\n",
                    replace_funny_characters(block_name));
}



static void vqm_print_lcell(FILE *outfile,
                              char *block_name,
                              char **pinlist,
                              int num_pins) {

   /* Print an logic cell to the vqm file */

   int ipin, num_lut_inputs_used;
   char *lut_mask;

   fprintf(outfile, "\n%s_lcell \\%s~I (\n",
                    get_architecture_prefix(),
                    replace_funny_characters(block_name));

   num_lut_inputs_used = 0;

   for(ipin = 0; ipin < lut_size; ipin++) {
      if(strcasecmp(pinlist[ipin], "open")) {
         fprintf(outfile, "\t.data%c(%s),\n",
                          'a' + ipin, vqm_internal_net_name(pinlist[ipin]));
         num_lut_inputs_used++;
      }
   }

   if(!strcasecmp(pinlist[lut_size], "open")) {
      fatal("no output from lcell");
   }

   /* Is the clock used by this logic cell ? */

   if(strcasecmp(pinlist[lut_size + 1], "open")) {
      fprintf(outfile, "\t.regout(%s),\n",
                       vqm_internal_net_name(pinlist[lut_size]));
      fprintf(outfile, "\t.clk(%s));\n",
                       vqm_internal_net_name(pinlist[lut_size + 1]));
   }
   else {
      fprintf(outfile, "\t.combout(%s));\n",
                       vqm_internal_net_name(pinlist[lut_size]));
   }

   fprintf(outfile, "defparam \\%s~I .operation_mode = \"normal\";\n",
                    replace_funny_characters(block_name));

   /* Make up a logic function for the LUT.  Try for NAND or inversion. */

   switch(num_lut_inputs_used) {

   case 0 :
      lut_mask = "FFFF";
      break;

   case 1 :
      lut_mask = "5555";
      break;

   case 2 :
      lut_mask = "7777";
      break;

   case 3 :
      lut_mask = "7F7F";
      break;

   case 4 :
      lut_mask = "7FFF";
      break;

   default :
      fatal("too many lut inputs");
      break;
   }

   fprintf(outfile, "defparam \\%s~I .lut_mask = \"%s\";\n",
                    replace_funny_characters(block_name),
                    lut_mask);
}



static char *get_architecture_prefix(void) {

   /* What is the prefix for VQM cell types for this architecture ? */

   switch(arch) {

   case ARCH_STRATIX :
      return("stratix");
      break;

   case ARCH_CYCLONE :
      return("cyclone");
      break;

   case ARCH_MAXII :
      return("maxii");
      break;

   default :
      fatal("unknown arch");
      return("unknown");
      break;
   }
}

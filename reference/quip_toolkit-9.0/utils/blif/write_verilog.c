/*
 * Revision Control Information
 *
 * $Source: /users/spathak/sis/sis-1.3.5/sis/io/write_verilog.c,v $
 * $Author: max $
 * $Revision: #1 $
 * $Date: 2008/11/28 $
 * 
 */

/**
 * Limitations:
 * 1. Does not support buses with non-contiguous range.
 * 2. In a bus, the highest index is always the MSB.
 * 3. any variable name in xx[dd] format will be interpreted as a bus.
 */

#include "sis.h"
#include "io_int.h"
#define MAX_NAMES 16500
#define MAX_STRLEN 256
#define MAX_BUS_SIZE 500
#define GLOBAL_CLK "gclk"

struct bus_struct
{
   char name[MAX_STRLEN+1];
   int indices[MAX_BUS_SIZE];
   int index_count;
   int min_index;
   int max_index;
};
typedef struct bus_struct bus;

struct list_node_struct
{
   //struct list_node_struct *prev;
   struct list_node_struct *next;
   char name[MAX_STRLEN+1];
};
typedef struct list_node_struct list_node;

list_node *declared_names = NULL;
bus buses[MAX_NAMES];
int bus_count = 0;
FILE *debug_file;

static void do_write_verilog();
static void write_verilog_nodes();
static void validate_name();
static int add_to_declared_names();
static int write_name();
static int is_a_bus();
static int add_to_buses();
static int is_index_defined();
static int find_bus_with_name();
static void process_all_names();
static int process_name();
static void declare_names();
static void write_inputs_outputs();
static list_node* add_to_list(list_node *list, char *name);
static int is_in_list(list_node *list, char *name);
static void delete_list(list_node *list);

#ifdef SIS
static void write_verilog_latches();
#endif /* SIS */

void
write_verilog_for_bdsyn(fp, network)
FILE *fp;
network_t *network;
{
    //io_fput_params("\\\n", 32000);
    io_fput_params(" \n",32000);
    do_write_verilog(fp, network, 0, 0);
}

static void validate_name(char *name, char*new_name)
{
    int n = strlen(name);
    int i,j = 0;
    char bus_name[MAX_STRLEN+1], new_bus_name[MAX_STRLEN+1], bus_index[11];
    int is_bus;

    //if a bus, validate the bus name
    (void)fprintf(debug_file,"\nStarting to validate the name: %s\n",name);
    is_bus = is_a_bus(name,bus_name);
    if(is_bus != -1)	    
    {
	(void)fprintf(debug_file,"\nIt is a bus, bus index %d\n",is_bus);
	validate_name(bus_name, new_bus_name);
	strcpy(new_name,new_bus_name);
	sprintf(bus_index,"[%d]",is_bus);
	strcat(new_name,bus_index);
	(void)fprintf(debug_file,"\nname validation done\n");
	return;
    }
    
   (void)fprintf(debug_file,"\nName is not a bus\n");
    for(i = 0; i < n; i++)
    {
       if((name[i] != '~') && ( name[i] != '.' )
		&& (name[i] != '[') && (name[i] != ']') )
       {
	   new_name[j] = name[i];
	   j++;
       }
    }
    new_name[j] = '\0';
    if(!isalpha(new_name[0]) && (new_name[0] != '_'))
    {
        char temp[MAX_STRLEN+1];
	strcpy(temp,new_name);
	new_name[0] = 'x';
	new_name[1] = '\0';
	strcat(new_name,temp);
    }
    (void)fprintf(debug_file,"\nname validation done\n");
}

static int add_to_declared_names(char *name, char *new_name)
{
   int i;
     
   validate_name(name,new_name);
   
   io_fprintf_break(debug_file,"\nIn add_to_declared_names, new name is %s",new_name);
   
   if(is_in_list(declared_names,new_name))   //name already declared
   {
 	io_fprintf_break(debug_file,"\nName already declared: %s",new_name);
        return 0;      
   }

   /*if(count >= MAX_NAMES)
   {
       (void)fprintf(siserr, "\nError: too many names in write_verilog!");
      exit(1);
   }
   else */
   if(strlen(new_name) > MAX_STRLEN-1)
   {
      (void)fprintf(siserr, "\nError: name too long in write_verilog!");
      exit(1);
   }

   //strcpy(declared_names[count],new_name);
   //added_name = (char *)malloc(strlen(new_name)+1);
   declared_names = add_to_list(declared_names,new_name);  
   
   io_fprintf_break(debug_file,"\nName added: %s\n",new_name);
   return 1;
}

//if the name is a bus, it assumes that it is already added to the buses array
// and that it is in xx format or xx[dd] format.
static int write_name(FILE *fp, char* name, char *new_name, int reg)
{
   io_fputs_break(debug_file,"\nEntered write_name, name: %s",name);
   int i, is_bus, bus_index;
   char bus_name[MAX_STRLEN+1];
   bus aBus;
   
   //check if it is a bus
   is_bus = is_a_bus(name,bus_name);
   if(is_bus == -1) 
	bus_index =  find_bus_with_name(name);
   else
	bus_index = find_bus_with_name(bus_name);
   
   if(bus_index == -1) //not a bus
   {
	i = add_to_declared_names(name,new_name);
        if(i == 1) //new name, need to declare
        {
	   if(reg)
	      io_fprintf_break(fp,"reg %s;\n",new_name);
           else	
	      io_fprintf_break(fp,"wire %s;\n",new_name);
	   io_fprintf_break(debug_file,"\nwire/reg declared: %s\n",new_name);
        }
   }
   else //a bus
   {
      aBus = buses[bus_index];
      if(is_bus == -1)
          i = add_to_declared_names(name,new_name);
      else
	  i = add_to_declared_names(bus_name, new_name);
      if(i == 1) //new name, need to declare
      {
	  if(reg)
	  {
             io_fprintf_break(fp,"reg [%d:%d] %s;\n", aBus.max_index, aBus.min_index, aBus.name);
	     (void)fprintf(debug_file,"\nbus %s declared, indices: %d and %d",aBus.name,aBus.max_index,aBus.min_index);
	  }
	  else
	  {
	     io_fprintf_break(fp,"wire [%d:%d] %s;\n", aBus.max_index, aBus.min_index, aBus.name);
	     (void)fprintf(debug_file,"\nbus %s declared, indices: %d and %d",aBus.name,aBus.max_index,aBus.min_index);
	  }
      }
   }
      
   return i;
}

void
write_verilog(fp, network, short_flag, netlist_flag)
FILE *fp;
network_t *network;
int short_flag;
int netlist_flag;
{
     int i;
    
    debug_file = com_open_file("debug.txt", "w", NIL(char *), /* silent */0);
    //debug_file = siserr;
    
    io_fput_params("\n",78);
    declared_names = NULL;
    bus_count = 0;
    
    (void)fprintf(debug_file,"\nbus_count reset to 0");
    do_write_verilog(fp, network, short_flag, netlist_flag);
    
    delete_list(declared_names);
    declared_names = NULL;
    bus_count = 0;
}

static void
write_verilog_cover(fp, p, short_flag)
FILE *fp;
node_t *p;
{
    register pset last, ps;
    register int c, i;
    list_node *inputs = NULL, *n = NULL;
    char tmp[MAX_STRLEN+1], new_name[MAX_STRLEN+1];
    static char dc[5];

    io_fputs_break(debug_file,"\nentered write_verilog_cover");
    strcpy(dc,"xxxx");
    dc[4] = '\0';
    
    if (p->type == PRIMARY_OUTPUT) 
    {
	return;
    }
    else 
    {
	io_fputs_break(debug_file,"\ninside else");
	int tmp_count = 0;
	char pname[MAX_STRLEN+1];
	list_node *temp_names = NULL;

	//write_name(fp,io_name(p,short_flag),pname,0);
	validate_name(io_name(p,short_flag),pname);
	foreach_set (p->F, last, ps)
       	{
	    for (i = 0; i < p->nin; i++) 
	    {
		c = "?01-"[GETINPUT(ps,i)];
		if(c == '1')
		{
		 //  io_fputs_break(debug_file,"c is 1");
		  validate_name(io_name(p->fanin[i],short_flag),tmp);
		  inputs = add_to_list(inputs,tmp);
		}
		else if(c == '-')
		{
		   //io_fputs_break(debug_file,"c is -");
		   //strcpy(inputs[i],dc);
		   inputs = add_to_list(inputs,dc);
		}
		else
		{
		   char tmp2[MAX_STRLEN+2];
		   strcpy(tmp2,"~");
		   //io_fputs_break(debug_file,"c is 0");
		   
		    validate_name(io_name(p->fanin[i],short_flag),tmp);
		   strcat(tmp2,tmp);
		   //strcpy(inputs[i], tmp2);
		   inputs = add_to_list(inputs,tmp2);
		   //io_fputs_break(debug_file,"c is 0 done");
		}
	    }
	    
	    strcpy(new_name,pname);
	    char cnt_str[12];
	    sprintf(cnt_str,"__%d",tmp_count);
	    strcat(new_name,cnt_str);
	    write_name(fp,new_name,tmp,0);
	    //validate_name(new_name,tmp);
	    temp_names = add_to_list(temp_names,tmp);
            io_fprintf_break(fp,"and(%s", tmp);
	    tmp_count++;

	    n = inputs;
	    while(n != NULL)
	    {
		if(strcmp(n->name,dc) != 0)
	       	   io_fprintf_break(fp,",%s",n->name);
		n = n->next;
	    }
	    io_fputs_break(fp,");\n");
	    delete_list(inputs);
	    inputs = NULL;
	}

	io_fprintf_break(fp,"or(%s",pname);
	n = temp_names;
	while(n != NULL)
	{
	    io_fprintf_break(fp,",%s",n->name);
	    n = n->next;
	}
	io_fputs_break(fp,");\n");
	delete_list(temp_names);
	temp_names = NULL;
    }
    io_fputs_break(debug_file,"\nwrite_verilog_cover done");
}


static void 
write_verilog_node(fp, n, short_flag, mapped)
register FILE *fp;
node_t *n;
int short_flag;
int mapped;
{
    int i, num_cube,j;
    node_t *fanin;
    node_cube_t cube;
    node_literal_t literal;
    lib_gate_t *gate;
    list_node *inputs = NULL, *l = NULL;
    char new_name[MAX_STRLEN+1], new_name2[MAX_STRLEN+1];
    
#ifdef SIS
    node_t *lpo;
    int mlatch;
#endif /* SIS */

   io_fprintf_break(debug_file,"\nentered write_verilog_node %s",io_name(n,short_flag));
    if (io_node_should_be_printed(n) == 0) {
         io_fprintf_break(debug_file,"\nnode should not be printed");
        return;
    }
    gate = lib_gate_of(n);

    if (mapped == 0 || gate == NIL(lib_gate_t))
    {
	io_fprintf_break(debug_file,"\n inside if, before switch..");
	switch(node_function(n))
	{
	   case NODE_0: io_fprintf_break(debug_file,"\n it is a 0!");
		        validate_name(io_name(n,short_flag),new_name);
			io_fprintf_break(fp,"assign %s = 1'b0;\n",new_name);break;
	   case NODE_1: io_fprintf_break(debug_file,"\n it is a 1!");
			validate_name(io_name(n,short_flag),new_name);
			io_fprintf_break(fp,"assign %s = 1'b1;\n",new_name);break;
	   case NODE_AND: io_fprintf_break(debug_file,"\n it is an and!");
			  validate_name(io_name(n,short_flag),new_name);
			  num_cube = node_num_cube(n);
			  for(j = 0; j < num_cube; j++)
			  {
			  cube = node_get_cube(n,j);
			  for(i = 0; i < n->nin; i++)
			  {
			     literal = node_get_literal(cube,i);
			     if(literal == ZERO)
			     {
				char tmp[MAX_STRLEN+2];
				validate_name(io_name(n->fanin[i],short_flag),new_name2);
				strcpy(tmp,"~");
				strcat(tmp,new_name2);
				inputs = add_to_list(inputs,tmp);
			     }
			     else if(literal == ONE)
			     {
				validate_name(io_name(n->fanin[i],short_flag),new_name2);
				inputs = add_to_list(inputs,new_name2);
			     }
			  }
			  }
			  io_fprintf_break(fp,"and(%s",new_name);
			  l = inputs;
			  while(l != NULL)
			  {
			     io_fprintf_break(fp,",%s",l->name);
			     l = l->next;
			  }
			  io_fputs_break(fp,");\n");
			  delete_list(inputs);
			  inputs = NULL;
			  break;
	   case NODE_OR:  io_fprintf_break(debug_file,"\n it is an or!");
                          validate_name(io_name(n,short_flag),new_name);
		          num_cube = node_num_cube(n);
			  //io_fprintf_break(fp,"//number of cubes: %d\n",j);
			  for(j = 0; j < num_cube; j++)
			  {
			  cube = node_get_cube(n,j);
			  //io_fprintf_break(fp,"//cube number: %d, literal: %d\n",j,i);
			   for(i = 0; i < n->nin; i++)
			   {
			     literal = node_get_literal(cube,i);
			     if(literal == ZERO)
			     {
				//io_fprintf_break(fp,"//%dth literal is zero: in cube %d\n",i,j);
				char tmp[MAX_STRLEN+2];
				//write_name(fp,io_name(n->fanin[i],short_flag),tmp,0);
			        validate_name(io_name(n->fanin[i],short_flag),new_name2);
				strcpy(tmp,"~");
				strcat(tmp,new_name2);
				inputs = add_to_list(inputs,tmp);
				//io_fprintf_break(fp,"//name is: %s\n",inputs[i]);

			     }
			     else if(literal == ONE)
			     {
				//io_fprintf_break(fp,"//%dth literal is one: in cube %d\n",i,j);
				 //write_name(fp,io_name(n->fanin[i],short_flag),inputs[i],0);
			        validate_name(io_name(n->fanin[i],short_flag),new_name2);
				inputs = add_to_list(inputs,new_name2);
			     }
			   }
			  }
			  io_fprintf_break(fp,"or(%s",new_name);
			  l = inputs;
			  while(l != NULL)
			  {
			     io_fprintf_break(fp,",%s",l->name);
			     l = l->next;
			  }
			  io_fputs_break(fp,");\n");
			  delete_list(inputs);
			  inputs = NULL;
			  break;
	   case NODE_INV: io_fprintf_break(debug_file,"\n it is an inverter!");
 			  validate_name(io_name(n,short_flag),new_name);
			  validate_name(io_name(n->fanin[0],short_flag),new_name2);
			  io_fprintf_break(fp,"not(%s,%s);\n",new_name,new_name2);
			  break;
	   case NODE_BUF: io_fprintf_break(debug_file,"\n it is a buffer!");
			  validate_name(io_name(n,short_flag),new_name);
			  validate_name(io_name(n->fanin[0], short_flag),new_name2);
			  io_fprintf_break(fp,"and(%s,%s);\n",new_name,new_name2);
			  break;
  	   case NODE_PO: io_fprintf_break(debug_file,"\n it is a PO!"); 
			 validate_name(io_name(n,short_flag),new_name);
			 validate_name(io_name(n->fanin[0], short_flag),new_name2);
			 io_fprintf_break(fp,"and(%s,%s);\n",new_name,new_name2);
			 break;
	   case NODE_PI: io_fprintf_break(debug_file,"\n it is a PI!");
		  	 break;
	   default:
	      io_fprintf_break(debug_file,"\n it is something else!");
	      write_verilog_cover(fp, n, short_flag);
	      break;
	}	
	    }
    else //predefined gate
    {
	io_fprintf_break(debug_file,"\n It is a pre-defined gate");
	io_fputs_break(fp,"\npredefined gate encountered");
    }
    io_fputs_break(debug_file,"\nwrite_verilog_node done");
}

static void write_inputs_outputs(FILE *fp, network_t *network, list_node *pr_inputs,
		list_node *pr_outputs)
{
  int j,flag,index;
  list_node *n = NULL;
  char name[MAX_STRLEN+1];
  bus aBus;
  
  io_fprintf_break(fp, "module %s(", network_name(network));
  n = pr_inputs;  
   while(n != NULL)
    {
       io_fprintf_break(fp,"%s,",n->name);
       n = n->next;
    }
    
    n = pr_outputs;
    if(n != NULL)
    {
       io_fputs_break(fp,n->name);
       n = n->next;
    }
    
    while(n != NULL)
    {
       io_fprintf_break(fp,",%s",n->name);
       n = n->next;
    }
    
    io_fputs_break(fp, ");\n");
    //io_fputc_break(fp,';');

    //io_fputs_break(debug_file,"writing input");
    flag = 1;

    n = pr_inputs;
    while(n != NULL)
    {
   	strcpy(name,n->name);
	(void)fprintf(debug_file,"\n writing input: %s",name);
	index = find_bus_with_name(name);
	if(index == -1)
	{
	   if(!flag)
      	     io_fputc_break(fp, ',');
    	   else
	   {
              io_fputs_break(fp,"input ");
    	      flag = 0;
	   }

    	   io_fputs_break(fp, name);
	}
	else //a bus
	{
           if(!flag)
	      io_fputs_break(fp,";\n");
	   io_fputs_break(fp,"input ");
	   aBus = buses[index];
	   io_fprintf_break(fp,"[%d:%d] %s;\n",aBus.max_index,aBus.min_index,name);
	   flag = 1;
	}
	n = n->next;
    }
   if(!flag) 
      io_fputs_break(fp,";\n");
   //io_fputs_break(debug_file,"writing output");
   flag = 1;

   //(void)fprintf(debug_file,"number of primary outputs: %d",po_count);
   n = pr_outputs;
   while(n != NULL)
   {
	strcpy(name,n->name);
	(void)fprintf(debug_file,"\n writing output: %s",name);
	index = find_bus_with_name(name);
	if(index == -1)
	{
	    if(!flag)
	       io_fputc_break(fp, ',');
            else
	    {
               io_fputs_break(fp,"output ");
               flag = 0;
	    }
            io_fputs_break(fp, name);
	}
	else //a bus
	{
	   if(!flag)
	      io_fputs_break(fp,";\n");
	   io_fputs_break(fp,"output ");
	   aBus = buses[index];
	   io_fprintf_break(fp,"[%d:%d] %s;\n",aBus.max_index,aBus.min_index,name);
	   flag = 1;
	}

       n = n->next;
    }
   if(!flag)   
      io_fputs_break(fp,";\n");
}

	
static void
do_write_verilog(        // fp, network, short_flag, netlist_flag)
register FILE *fp,
network_t *network,
int short_flag,
int netlist_flag)
{
    node_t *p;
    lsGen gen;
    node_t *node, *po, *fanin, *pnode;
    node_t *nodein;
    network_t *dc_net;
    char *name;
    int po_cnt;
    int flag = 0;
    char new_name[MAX_STRLEN+3];
    list_node *pr_inputs = NULL, *pr_outputs = NULL;
    int gclk_added = 0;

#ifdef SIS
    graph_t *stg;
    st_generator *stgen;
    node_t *pi_node, *po_node, *buf_node;
        latch_t *latch;

   /*
    * Traverse thru all the latches to find out if there is a latch without control
    * input.
    * */
	
    //latch_t *latch;
    node_t *control;
       
    (void)fprintf(debug_file,"\n processing latches");
    foreach_latch (network, gen, latch) 
    {
       if((latch_get_control(latch) == NIL(node_t)) && (latch_get_type(latch) != ASYNCH))
       {
	  if(!gclk_added)
	  {
	      gclk_added = 1;
	      (void)fprintf(siserr, "Warning: latch(es) without control encountered, global clock added to inputs.\n");
          }
       }
    }
#endif /* SIS */
    (void)fprintf(debug_file,"\n calling process_all_names");
    process_all_names(network,short_flag,netlist_flag,&pr_inputs,&pr_outputs);
    if(gclk_added)
    {
       pr_inputs = add_to_list(pr_inputs,GLOBAL_CLK);
    }
    
    write_inputs_outputs(fp, network,pr_inputs,pr_outputs);
    declare_names(fp,network,short_flag,netlist_flag);
        
#ifdef SIS
    write_verilog_latches(fp, network, short_flag, netlist_flag);
#endif
   write_verilog_nodes(fp, network, netlist_flag, short_flag);
   io_fputs_break(fp, "endmodule");
   delete_list(pr_inputs);
   pr_inputs = NULL;

   delete_list(pr_outputs);
   pr_outputs = NULL;
}

static void
write_verilog_nodes(fp, network, netlist_flag, short_flag)
FILE *fp;
network_t *network;
int netlist_flag, short_flag;
{
    lsGen gen;
    node_t *p;
    
    io_fprintf_break(debug_file,"\nin write_verilog_nodes...\n");
    foreach_node (network, gen, p) {
	if (netlist_flag != 0 && lib_gate_of(p) != NIL(lib_gate_t)) {
#ifdef SIS
	    if (io_lpo_fanout_count(p, NIL(node_t *)) == 0) {
		/*
		 * Avoid the dummy nodes due to the latches
		 */
		//io_fprintf_break(debug_file,"\ninside if/if/if,processing node %s",io_name(p,short_flag));    
		io_fprintf_break(debug_file,"\n writing node: %s", io_name(p,short_flag));	
	    	    write_verilog_node(fp, p, short_flag,1);
	    }
#else
	  io_fprintf_break(debug_file,"\n,processing node %s",io_name(p,short_flag));
	   write_verilog_node(fp, p, short_flag,1);
	    
#endif /* SIS */
	}
	else {
            io_fprintf_break(debug_file,"\ninside else,processing node %s",io_name(p,short_flag));		
	    write_verilog_node(fp, p, short_flag,0);
	}
    }
    io_fputs_break(debug_file,"\n write_verilog_nodes done.\n");
}

#ifdef SIS

static void
write_verilog_latches(fp, network, short_flag, netlist_flag)
FILE *fp;
network_t *network;
int short_flag, netlist_flag;
{
    lsGen gen;
    latch_t *latch;
    node_t *node, *control;
    char control_name[MAX_STRLEN+1], input_name[MAX_STRLEN+1], output_name[MAX_STRLEN+1];
    char type_name[MAX_STRLEN+1];
    int init_value;
    latch_synch_t type;
    
    //io_fputs_break(debug_file,"\nEntering write_verilog_latches");
    foreach_latch (network, gen, latch) 
    {
        control = latch_get_control(latch);
	validate_name(io_name(latch_get_input(latch),short_flag),input_name);
       	validate_name(io_name(latch_get_output(latch),short_flag),output_name);
        type = latch_get_type(latch); 
	if(type == ASYNCH)
	{
	   //convert to a buffer
	    io_fprintf_break(fp,"and(%s,%s);\n",output_name,input_name);
	    return;
	}
		
	//write_name(fp,io_name(latch_get_input(latch),short_flag),input_name,0);
       	//write_name(fp,io_name(latch_get_output(latch),short_flag),output_name,1);
	
	if(control != NIL(node_t))
	{ 
	     //write_name(fp,io_name(control,short_flag),control_name,0);
	     validate_name(io_name(control,short_flag),control_name);
        } 
	else
	{
            strcpy(control_name,GLOBAL_CLK);
	}

   	switch (type)
	{
	  case RISING_EDGE:
	       strcpy(type_name,"posedge ");
	       strcat(type_name,control_name);
	       break;
	  case FALLING_EDGE:
	       strcpy(type_name,"negedge ");
	       strcat(type_name,control_name);
	       break;
  	  case ACTIVE_HIGH:
	  case ACTIVE_LOW:
	       strcpy(type_name,control_name);
	       break;
	  case ASYNCH:(void)fprintf(siserr,"\nHow did I get asynch latch here?");
		      exit(1);
          case UNKNOWN:
	       strcpy(type_name,"posedge  ");
	       strcat(type_name,control_name);
	       break;
	}


	//write the initial block in needed
    	init_value = latch_get_initial_value(latch);
	if(init_value == 0)
	{
	    io_fputs_break(fp,"initial begin\n");
            io_fprintf_break(fp,"%s = 1'b0;\n",output_name);	    
	    io_fputs_break(fp,"end\n");
	}
	else if(init_value == 1)
	{
	   io_fputs_break(fp,"initial begin\n");
           io_fprintf_break(fp,"%s = 1'b1;\n",output_name);	    
	   io_fputs_break(fp,"end\n");
	}

	//write the always block
	io_fprintf_break(fp,"always@(%s)\nbegin\n",type_name);
	if(type == ACTIVE_HIGH)
	   io_fprintf_break(fp,"if(%s)\n",control_name);
	else if(type == ACTIVE_LOW)
	   io_fprintf_break(fp,"if(!%s)\n",control_name);
	io_fprintf_break(fp,"%s = %s;\n",output_name,input_name);
	io_fputs_break(fp,"end\n");
    }

    //io_fputs_break(debug_file,"\nwrite_verilog_latches done");
}
#endif /* SIS */

//returns -1 if not a bus, otherwise returns the index (the num between [ and ])
//does NOT check in the buses array, just checks the name for a xx[dd] pattern
static int is_a_bus(char *name, char* bus_name)
{
   int i,j=0;
   int len = strlen(name);
   char index_str[MAX_STRLEN+1];
   int index, bus_index;
   
   for(i = 0; i < len; ++i)
   {
      if(name[i] == '[')
	 break;
      else
      {
	 bus_name[j] = name[i];
	 ++j;
      }
   }
   if(i == 0) //first character is '[', not a bus
      return -1;
   if(i == len) //no '[', not a bus
      return -1;

   //may be a bus.
   bus_name[j] = '\0';
   ++i;
   j = 0;
   if((name[i] == '-') || (isdigit(name[i])))
   {
      index_str[j] = name[i];
      ++i;
      ++j;
   }
   else
      return -1; //the character after '[' is not a digit or a '-'; not a bus
   
   for(; i < len; ++i)
   {
       if(name[i] == ']')
	  break;
       else if(isdigit(name[i]))
       {
         index_str[j] = name[i];
	 j++;
       }
       else
	 return -1; //charcters after '[' are not digits; not a bus
   }	
   if(i == len)
      return -1; //no ']'; not a bus

   //may be a bus
   index_str[j] = '\0';
   if(i != (len-1))
      return -1; //']'is not the last character; not a bus

   index = atoi(index_str);
   return index;
}

static int add_to_buses(char *name, int index)
{
   bus aBus;
   int bus_index = find_bus_with_name(name);

   io_fprintf_break(debug_file,"\nadd_to_buses: %s, index is: %d",name,index);
   if(bus_index == -1) //new bus
   {
      strcpy(aBus.name,name);
      aBus.indices[0] = index;
      aBus.index_count = 1;
      aBus.min_index = index;
      aBus.max_index = index;
      buses[bus_count] = aBus;
      ++bus_count;
      io_fputs_break(debug_file,"\n added to buses");
      return 1;
   }
   else if(!is_index_defined(buses[bus_index],index))
   {
      aBus = buses[bus_index];
      if(aBus.index_count >= MAX_BUS_SIZE)
      {
	  (void)fprintf(siserr,"\nBus %s is too large!",aBus.name);
	  exit(1);
      }
      aBus.indices[aBus.index_count] = index;
      (void)fprintf(debug_file,"\nindex %d is inserted at position %d",index,aBus.index_count);
      ++(aBus.index_count);
      if(index < aBus.min_index)
	 aBus.min_index = index;
      if(index > aBus.max_index)
	 aBus.max_index = index;
      buses[bus_index] = aBus;
      io_fputs_break(debug_file,"\n no need to add to bus");
      return 0;
   }
   return 0;
}

static int find_bus_with_name(char* name)
{
   int j;
   for(j = 0; j < bus_count; j++)
   {
      bus aBus = buses[j];
      if(strcmp(aBus.name, name) == 0)
      {
	 return j;
      }
   }

   return -1;
}

static int is_index_defined(bus aBus, int index)
{
   int j;
   (void)fprintf(debug_file,"\nlooking for index %d in bus %s",index,aBus.name);
   (void)fprintf(debug_file,"\nmin index %d, max_index %d",aBus.min_index,aBus.max_index);
   for(j = 0; j < aBus.index_count; j++)
   {
      (void)fprintf(debug_file,"\n index %d is %d",j,aBus.indices[j]);
      if(aBus.indices[j] == index)
	 return 1;
   }

   return 0;
}

static void process_all_names(network_t *network, int short_flag, int netlist_flag,
       	list_node **p_pr_inputs,list_node **p_pr_outputs)
{
    node_t *p, *control;
    lsGen gen;
    int is_bus, bus_status,j;
    char bus_name[MAX_STRLEN+1], new_name[MAX_STRLEN+1];
    latch_t *latch;
    list_node *pr_inputs = *p_pr_inputs;
    list_node *pr_outputs = *p_pr_outputs;
    
    //primary inputs
    foreach_primary_input (network, gen, p)
    {
#ifdef SIS
	if (network_is_real_pi(network, p) != 0 &&
			clock_get_by_name(network, node_long_name(p)) == 0) 
	{
	   is_bus = is_a_bus(io_name(p,short_flag), bus_name);
	   if(is_bus == -1) //not a bus
	   {
	      //add_to_declared_names(io_name(p,short_flag),new_name);
	      //io_fputs_break(fp,new_name);
	      validate_name(io_name(p,short_flag), new_name);
	      pr_inputs = add_to_list(pr_inputs,new_name);
	      //io_fputc_break(fp, ',');
	   }
	   else //a bus
	   {
             validate_name(bus_name, new_name);
	     bus_status = add_to_buses(new_name,is_bus);
	     if(bus_status)
	     {                
	        pr_inputs = add_to_list(pr_inputs,new_name);
	     }
	   }
	}
#else 
	is_bus = is_a_bus(io_name(p,short_flag), bus_name);
	if(is_bus == -1) //not a bus
	{
	    validate_name(io_name(p,short_flag), new_name);
	    pr_inputs = add_to_list(pr_inputs,new_name);
	}
	else //a bus
	{
            validate_name(bus_name, new_name);
	    bus_status = add_to_buses(new_name,is_bus);
	    if(bus_status)
	    {                
	       pr_inputs = add_to_list(pr_inputs,new_name);
	    }
	}
#endif // SIS 
    }

    //primary outputs
    (void)fprintf(debug_file,"\n processing primary outputs");
    foreach_primary_output (network, gen, p) 
    {
#ifdef SIS
        if (network_is_real_po(network, p) != 0) 
	{
	    is_bus = is_a_bus(io_name(p,short_flag), bus_name);
	    (void)fprintf(debug_file,"\nname is: %s", io_name(p,short_flag));
	   if(is_bus == -1) //not a bus
	   {
	      (void)fprintf(debug_file,"\n not a bus");
	      validate_name(io_name(p,short_flag), new_name);
	      pr_outputs = add_to_list(pr_outputs,new_name);
	      (void)fprintf(debug_file,"\nname %s added to primary outputs",new_name);
	   }
	   else //a bus
	   {
	     (void)fprintf(debug_file,"\n it is a bus");
             validate_name(bus_name, new_name);
	     bus_status = add_to_buses(new_name,is_bus);
	     if(bus_status)
	     {                
	        pr_outputs = add_to_list(pr_outputs,new_name);
		(void)fprintf(debug_file,"\nname %s added to primary outputs",new_name);
	     }
	   }
	}
#else
	(void)fprintf(debug_file,"\nname is: %s", io_name(p,short_flag));
	 is_bus = is_a_bus(io_name(p,short_flag), bus_name);
	   if(is_bus == -1) //not a bus
	   {
	      (void)fprintf(debug_file,"\n not a bus");
	      validate_name(io_name(p,short_flag), new_name);
	      pr_outputs = add_to_list(pr_outputs,new_name);
	      (void)fprintf(debug_file,"\nname %s added to primary outputs");
	   }
	   else //a bus
	   {
	     (void)fprintf(debug_file,"\n it is a bus");
             validate_name(bus_name, new_name);
	     bus_status = add_to_buses(new_name,is_bus);
	     if(bus_status)
	     {                
	        pr_outputs = add_to_list(pr_outputs,new_name);
	        (void)fprintf(debug_file,"\nname %s added to primary outputs");
	     }
	   }
#endif // SIS 
    }
#ifdef SIS
    //process latches
    foreach_latch (network, gen, latch) 
    {
	control = latch_get_control(latch);
	if(control != NIL(node_t))
	   process_name(io_name(control,short_flag));
	process_name(io_name(latch_get_input(latch),short_flag));
	process_name(io_name(latch_get_output(latch),short_flag));
    }
#endif
    //process other nodes
    foreach_node (network, gen, p) 
    {
	if (netlist_flag != 0 && lib_gate_of(p) != NIL(lib_gate_t)) 
	{
#ifdef SIS
	    if (io_lpo_fanout_count(p, NIL(node_t *)) == 0) 
	    {
	        process_name(io_name(p,short_flag));
                for(j = 0; j < p->nin; j++)
		{
		   process_name(io_name(p->fanin[j],short_flag));
		}		
	    }
#else
	   process_name(io_name(p,short_flag));
           for(j = 0; j < p->nin; j++)
	   {
	      process_name(io_name(p->fanin[j],short_flag));
	   }	
#endif // SIS 
	}    
	else
	{
	   process_name(io_name(p,short_flag));
           for(j = 0; j < p->nin; j++)
	   {
	      process_name(io_name(p->fanin[j],short_flag));
	   }	
	}	
    }

    *p_pr_inputs = pr_inputs;
    *p_pr_outputs = pr_outputs;
}

static int process_name(char name[])
{
   int is_bus,bus_status = 0;
   char bus_name[MAX_STRLEN+1],new_name[MAX_STRLEN+1];
   
   is_bus = is_a_bus(name, bus_name);
   if(is_bus != -1) //a bus
   {
     validate_name(bus_name, new_name);
     bus_status = add_to_buses(new_name,is_bus);
   }
   return bus_status;
}

static void declare_names(FILE *fp, network_t *network, int short_flag, int netlist_flag)
{
   node_t *p, *control;
    lsGen gen;
    int is_bus, bus_status,j;
    char bus_name[MAX_STRLEN+1], new_name[MAX_STRLEN+1];
    latch_t *latch;

#ifdef SIS
    //process latches
    foreach_latch (network, gen, latch) 
    {
        write_name(fp,io_name(latch_get_output(latch),short_flag),new_name,1);
    }

    foreach_latch (network, gen, latch) 
    {
	control = latch_get_control(latch);
	if(control != NIL(node_t))
	   write_name(fp,io_name(control,short_flag),new_name,0);
	write_name(fp,io_name(latch_get_input(latch),short_flag),new_name,0);
    }
#endif

    //process inputs
    foreach_primary_input (network, gen, p)
    {
#ifdef SIS
	if (network_is_real_pi(network, p) != 0 &&
			clock_get_by_name(network, node_long_name(p)) == 0) 
	{
	   write_name(fp,io_name(p,short_flag), new_name,0);
	}
#else 
	write_name(fp,io_name(p,short_flag), new_name,0);
#endif // SIS 
    }

    //process outputs
    foreach_primary_output (network, gen, p) 
    {
#ifdef SIS
        if (network_is_real_po(network, p) != 0) 
	{
	   write_name(fp,io_name(p,short_flag), new_name,0);
   	}
#else
	 write_name(fp,io_name(p,short_flag), new_name,0);
#endif // SIS 
    }

    //process other nodes
    foreach_node (network, gen, p) 
    {
	if (netlist_flag != 0 && lib_gate_of(p) != NIL(lib_gate_t)) 
	{
#ifdef SIS
	    if (io_lpo_fanout_count(p, NIL(node_t *)) == 0) 
	    {
	        write_name(fp,io_name(p,short_flag),new_name,0);
                for(j = 0; j < p->nin; j++)
		{
		   write_name(fp,io_name(p->fanin[j],short_flag),new_name,0);
		}		
	    }
#else
	   write_name(fp,io_name(p,short_flag),new_name,0);
           for(j = 0; j < p->nin; j++)
	   {
	      write_name(fp,io_name(p->fanin[j],short_flag),new_name,0);
	   }	
#endif // SIS 
	}    
	else
	{
	   write_name(fp,io_name(p,short_flag),new_name,0);
           for(j = 0; j < p->nin; j++)
	   {
	      write_name(fp,io_name(p->fanin[j],short_flag),new_name,0);
	   }	
	}	
    }

}

//functions to manage linked list
static list_node* add_to_list(list_node *list, char *name)
{
   list_node *tmp = list;
   list = (list_node*)malloc(sizeof(list_node));

   if(list == NULL)
   {
	(void)fprintf(siserr,"\n Out of memory!");
	exit(1);
   }
   //list->name = (char *)malloc(strlen(name)+1)
   strcpy(list->name,name);
   list->next = tmp;
   return list;
}

static int is_in_list(list_node *list, char *name)
{
   list_node *n = NULL;
   n = list;
   
   while(n != NULL)
   {
      if(strcmp(n->name,name) == 0)
      {
	return 1;		 
      }
      n = n->next;
   }
   return 0;
}

static void delete_list(list_node *list)
{
   list_node *n = NULL;
   
   while(list != NULL)
   {
     n = list->next;  
     //free(n->name);
     free(list);
     list = n;
   }
   n = NULL;
}

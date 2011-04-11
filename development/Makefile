CFLAGS=-Wall -Wextra --std=gnu99 -g
TARGETS=read_pof

all: ${TARGETS}

read_pof: read_pof.o pof.o
	gcc ${CFLAGS} -o $@ $^

%.o: %.c
	gcc ${CFLAGS} -c -o $@ $<

clean:
	rm -f *.o ${TARGETS}


#
# Makefile for buckygen
#

SHELL = /bin/sh
CFLAGS += -O3

all : clean buckygen

buckygen :
	${CC} $(CFLAGS) buckygen.c -o buckygen

prof :
	rm -rf buckygen-prof gmon.out
	${CC} -pg -g buckygen.c -o buckygen-prof

stats :
	rm -rf buckygen-stats
	${CC} $(CFLAGS) -DSTATS buckygen.c -o buckygen-stats

clean :
	rm -f buckygen

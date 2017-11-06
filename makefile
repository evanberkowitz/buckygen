#
# Makefile for buckygen
#

SHELL = /bin/sh
CC = gcc
CFLAGS = -O4

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

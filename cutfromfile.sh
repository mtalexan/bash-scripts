#!/bin/bash

#Outputs the contents between the two line numbers specified, including the lines specified

if [ -u $1 ] || [ -u $2 ] || [ -u $3 ] ; then
    echo "USAGE: $0 file StartLineNum EndLineNum"
    exit 1
fi

FILE=$1
LINESTART=$2
LINEEND=$3

if [ ! -f $FILE ] ; then
    >&2 echo "File \"$FILE\" cannot be read"
    exit 1
fi

LINETOTAL=`wc -l $FILE | awk '{print $1}'`

#Clip to ending at the total number of lines
if [ $LINEEND -gt $LINETOTAL ] ; then
    LINEEND=$LINETOTAL
fi
#make sure START less than or equal to END
if [ $LINESTART -gt $LINEEND ] ; then
    #Nothing between the lines, so just exit with empty
    exit 0
fi

LINESOFFEND=`expr $LINETOTAL - $LINEEND`

head -n -$LINESOFFEND $FILE | tail -n +$LINESTART

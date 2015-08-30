#!/usr/bin/env bash
#* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#*                                                                           *
#*            This file is part of the test engine for MIPLIB2010            *
#*                                                                           *
#* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
# $Id: evalrun.sh,v 1.1 2010/12/09 22:22:28 bzfheinz Exp $

AWKARGS=""
FILES=""
for i in $@
do
    if test ! -e $i
    then
	AWKARGS="$AWKARGS $i"
    else
	FILES="$FILES $i"
    fi
done

for i in $FILES
do
    NAME=`basename $i .out`
    DIR=`dirname $i`
    OUTFILE=$DIR/$NAME.out
    RESFILE=$DIR/$NAME.res

    SOLVER=`echo $NAME | sed 's/check.\([a-zA-Z0-9_-]*\).\([a-zA-Z0-9_-]*\).*/\2/g'`

    awk -f parse.awk -f $SOLVER/parse_$SOLVER.awk $OUTFILE | tee $RESFILE
done

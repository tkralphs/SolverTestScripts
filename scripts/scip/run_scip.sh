#* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#*                                                                           *
#*            This file is part of the test engine for MIPLIB2010            *
#*                                                                           *
#* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
# $Id: run_scip.sh,v 1.2 2010/12/14 20:24:10 bzfheinz Exp $

SOLVER=$1
BINNAME=$2
NAME=$3
TIMELIMIT=$4
SOLFILE=$5
THREADS=$6
MIPGAP=$7

TMPFILE=results/check.$SOLVER.tmp

echo > $TMPFILE
echo > $SOLFILE

# set threads to given value 
# nothing to be done for SCIP

# set mipgap to given value
echo set limits gap $MIPGAP            >> $TMPFILE

# set timing to wall-clock time and pass time limit
echo set timing clocktype 2            >> $TMPFILE
echo set limits time $TIMELIMIT        >> $TMPFILE

# use deterministic mode (warning if not possible) 
# nothing to be done for SCIP

# set display options
echo set display freq 10000            >> $TMPFILE 
echo set display verblevel 4           >> $TMPFILE

# read, optimize, display statistics, write solution, and exit
echo read $NAME                        >> $TMPFILE
echo optimize                          >> $TMPFILE
echo display statistics                >> $TMPFILE
echo write solution $SOLFILE           >> $TMPFILE
echo quit                              >> $TMPFILE

$BINNAME < $TMPFILE 

if test -e $SOLFILE
then
    # translate SCIP solution format into format for solution checker. The
    # SOLFILE format is a very simple format where in each line we have a
    # <variable, value> pair, separated by spaces.  A variable name of
    # =obj= is used to store the objective value of the solution, as
    # computed by the solver. A variable name of =infeas= can be used to
    # indicate that an instance is infeasible.
    sed ' /solution status:/d;
            s/objective value:/=obj=/g;
            s/no solution available/=infeas=/g' $SOLFILE > $TMPFILE
    mv $TMPFILE $SOLFILE
fi

rm $TMPFILE

#* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#*                                                                           *
#*            This file is part of the test engine for MIPLIB2010            *
#*                                                                           *
#* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
# $Id: run_cplex.sh,v 1.4 2010/12/14 20:24:09 bzfheinz Exp $

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

# disable log file
echo set logfile '*'                   >> $TMPFILE

# set threads to given value 
if test $THREADS != 0
then
    echo set threads $THREADS          >> $TMPFILE
fi

# set mipgap to given value
echo set mip tolerances mipgap $MIPGAP >> $TMPFILE

# set timing to wall-clock time and pass time limit
echo set clocktype 2                   >> $TMPFILE
echo set timelimit $TIMELIMIT          >> $TMPFILE

# use deterministic mode (warning if not possible) 
echo set parallel 1                    >> $TMPFILE

# set display options
# nothing for CPLEX

# read, optimize, display statistics, write solution, and exit
echo read $NAME                        >> $TMPFILE
echo change sense 0                    >> $TMPFILE  # to identify obj sense
echo                                   >> $TMPFILE
echo optimize                          >> $TMPFILE
echo set logfile $SOLFILE              >> $TMPFILE
echo display solution objective        >> $TMPFILE
echo display solution variables -      >> $TMPFILE
echo set logfile '*'                   >> $TMPFILE
echo quit                              >> $TMPFILE

$BINNAME < $TMPFILE 

if test -f $SOLFILE
then
    # translate CPLEX solution format into format for solution checker.
    #  The SOLFILE format is a very simple format where in each line 
    #  we have a <variable, value> pair, separated by spaces. 
    #  A variable name of =obj= is used to store the objective value 
    #  of the solution, as computed by the solver. A variable name of 
    #  =infeas= can be used to indicate that an instance is infeasible.
    sed  ' /^Log started.*/d;
             /^Incumbent solution.*/d;
             /^Variable Name.*/d;
             /^All other variables in the range.*/d;
             /^No.* feasible solution exists.$/d;
	     /^MIP - Time limit exceeded, no integer solution.*/d;
             /^$/d;
            s/.*Objective = \([0-9\.eE+-]*\)/=obj=                        \1/g;
            s/.*infeasible\.$/=infeas=/g' $SOLFILE >$SOLFILE.tmp
    mv $SOLFILE.tmp $SOLFILE
fi

# remove tmp file
rm $TMPFILE

# remove CPLEX log 
rm cplex.log

#* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#*                                                                           *
#*            This file is part of the test engine for MIPLIB2010            *
#*                                                                           *
#* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
# $Id: run_gurobi.sh,v 1.5 2010/12/14 20:24:10 bzfheinz Exp $

SOLVER=$1
BINNAME=$2
NAME=$3
TIMELIMIT=$4
SOLFILE=$5
THREADS=$6
MIPGAP=$7


###########################################################
# version using gurobi_cl (ObjVal missing in solution file)
###########################################################
echo > $SOLFILE

# set mipgap to given value
# set timing to wall-clock time and pass time limit
# use deterministic mode (warning if not possible) 
# read, optimize, display statistics, write solution, and exit
$BINNAME TimeLimit=$TIMELIMIT ResultFile=$SOLFILE MIPGap=$MIPGAP $NAME

if test -e $SOLFILE
then
    # translate GUROBI solution format into format for solution checker.
    #  The SOLFILE format is a very simple format where in each line 
    #  we have a <variable, value> pair, separated by spaces. 
    #  A variable name of =obj= is used to store the objective value 
    #  of the solution, as computed by the solver. A variable name of 
    #  =infeas= can be used to indicate that an instance is infeasible.
    if test ! -s $SOLFILE
    then
	# empty file, i.e., no solution given 
	echo "=infeas=" > $SOLFILE
    else
        sed ' /Solution for/d' $SOLFILE > $SOLFILE.tmp
	mv $SOLFILE.tmp $SOLFILE
    fi
fi

rm gurobi.log


###########################################################
# version using gurobi.sh (provides ObjVal in solution file)
############################################################
#TMPFILE=results/check.$SOLVER.tmp
#
#echo > $TMPFILE
#echo > $SOLFILE
#
#echo "from gurobipy import *"               >> $TMPFILE
#echo "print ''"                             >> $TMPFILE   
#echo "print 'Gurobi Optimizer version %s' % '.'.join(str(x) for x in gurobi.version())" >> $TMPFILE
#echo "print ''"                             >> $TMPFILE   
#
## reset log file
#echo "setParam(\"LogFile\",\"gurobi.log\")" >> $TMPFILE
#
## set threads to given value 
#if test $THREADS != 0
#then
#    echo "setParam(\"Threads\",$THREADS)"   >> $TMPFILE
#fi
#
## set mipgap to given value
#echo "setParam(\"MIPGap\",$MIPGAP)"         >> $TMPFILE
#
## set timing to wall-clock time and pass time limit
#echo "setParam(\"TimeLimit\",$TIMELIMIT)"   >> $TMPFILE
#
## use deterministic mode (warning if not possible) 
## nothing to be done for Gurobi
#
## set display options
## nothing for Gurobi
#
## read, optimize, display statistics, write solution, and exit
#echo "problem=read(\"$NAME\")"              >> $TMPFILE
#echo "problem.optimize()"                   >> $TMPFILE
#echo "setParam(\"LogFile\",\"$SOLFILE\")"   >> $TMPFILE
#echo "if problem.SolCount > 0: "            >> $TMPFILE
#echo "  problem.printAttr('ObjVal')"        >> $TMPFILE
#echo "  problem.printAttr('X')"             >> $TMPFILE
##echo "  print '=obj=', problem.ObjVal"      >> $TMPFILE # more digits but output not passed to LogFile ????????
##echo "  for v in problem.getVars():"        >> $TMPFILE 
##echo "    print v.VarName, v.X"             >> $TMPFILE # more digits but output not passed to LogFile ????????
#echo "setParam(\"LogFile\",\"gurobi.log\")" >> $TMPFILE
#echo "quit()"                               >> $TMPFILE
#
#$BINNAME < $TMPFILE
#
#if test -f $SOLFILE
#then
#    # translate GUROBI solution format into format for solution checker.
#    #  The SOLFILE format is a very simple format where in each line 
#    #  we have a <variable, value> pair, separated by spaces. 
#    #  A variable name of =obj= is used to store the objective value 
#    #  of the solution, as computed by the solver. A variable name of 
#    #  =infeas= can be used to indicate that an instance is infeasible.
#    sed  ' /^Logging started.*/d;
#             /^Gurobi.*/d;
#             /.*ObjVal/{
#	       N
#               N
#               N
#               s/.*ObjVal\n----------\n\([0-9\.eE+-]*\)/=obj= \1/
#             };
#             /^  Variable         X/d;
#             /^---------------------/d' $SOLFILE > $TMPFILE
#    mv $TMPFILE $SOLFILE
#fi
#
#rm $TMPFILE
#rm gurobi.log








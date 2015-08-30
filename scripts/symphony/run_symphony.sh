#* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#*                                                                           *
#*            This file is part of the test engine for MIPLIB2010            *
#*                                                                           *
#* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
# $Id: run_cbc.sh,v 1.3 2010/12/20 13:36:43 bzfheinz Exp $

SOLVER=$1
BINNAME=$2
NAME=$3
TIMELIMIT=$4
SOLFILE=$5
THREADS=$6
MIPGAP=$7

TMPFILE=results/check.$SOLVER.tmp

echo > $SOLFILE

echo use_hot_starts 0 > sym.par

if test $THREADS != 0
then
    $BINNAME -F $NAME -t $TIMELIMIT -p $THREADS | tee $SOLFILE
else
    $BINNAME -F $NAME -t $TIMELIMIT | tee $SOLFILE
fi

if test -f $SOLFILE
then
    # translate CBC solution format into format for solution checker.
    #  The SOLFILE format is a very simple format where in each line 
    #  we have a <variable, value> pair, separated by spaces. 
    #  A variable name of =obj= is used to store the objective value 
    #  of the solution, as computed by the solver. A variable name of 
    #  =infeas= can be used to indicate that an instance is infeasible.
    awk '
          BEGIN{
             solution_found = 0;
             count = 0;
          }

          /^Solution Cost/ {
             printf ("=obj= %s \n", $3);
          }
          /^Branch and Cut / {
             printf ("=infeas= \n");
          }
          /^Column names/{
             solution_found = 1;
          }
          //{
             if (solution_found){
                count++;
                if (count > 2){
                   printf ("%s %s \n", $1, $2);
                }
             }
          }' $SOLFILE | tee $TMPFILE
    mv $TMPFILE $SOLFILE
fi

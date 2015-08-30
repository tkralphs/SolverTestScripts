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

if test $THREADS != 0
then
    $BINNAME -import $NAME -sec $TIMELIMIT -threads $THREADS -ratio $MIPGAP -solve -solution $SOLFILE
else
    $BINNAME -import $NAME -sec $TIMELIMIT -ratio $MIPGAP -solve -solution $SOLFILE
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
    /^Stopped/ {
        if( NF > 7 )
          exit;

	printf ("=obj= %s \n", $7);
        next;
    }
    /^Optimal/ {
	printf ("=obj= %s \n", $5);
        next;
    }
    /^Infeasible/ {
	printf ("=infeas= \n");
        exit;
    }
    /^Integer/ {
       if( $2 == "infeasible") 
	printf ("=infeas= \n");
        exit;
    }
    //{
        printf ("%s %s \n", $2, $3);
    }' $SOLFILE | tee $TMPFILE
    mv $TMPFILE $SOLFILE
fi

#* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#*                                                                           *
#*            This file is part of the test engine for MIPLIB2010            *
#*                                                                           *
#* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
# $Id: run.sh,v 1.4 2010/12/14 13:45:18 bzfheinz Exp $

SHELL=bash
BINNAME=vrp
TSTNAME=vrplib
TIMELIMIT=$1
#HARDMEMLIMIT=$5
THREADS=$2

# construct paths
MIPLIBPATH=`pwd`
BINPATH=/home/ted/SYMPHONY/trunk/build-polyps-static-openmp/SYMPHONY/Applications/VRP
CHECKERPATH=$MIPLIBPATH/checker
RESULTSPATH=$MIPLIBPATH/results
SCRIPTPATH=$MIPLIBPATH/scripts
TSTPATH=/home/ted/DataSets/VRP

# check if the solver link (binary) exists
if test ! -e $BINPATH/$BINNAME
then
    echo "ERROR: solver link <$BINNAME> does not exist in <bin> folder; see bin/README"
    exit;
fi

# check if the test set file/link exists
if test ! -e $TSTPATH
then
    echo "ERROR: test set file/link <$TSTNAME.test> does not exist in <testset> folder"
    exit;
fi

# grep solver name 
SOLVER=`echo $BINNAME | sed 's/\([a-zA-Z0-9_-]*\).*/\1/g'`

# check if the result folder exist. if not create the result folder
if test ! -e $RESULTSPATH
then
    mkdir $RESULTSPATH
fi

# construct name of output, results, and temporary solution file  
BASENAME=$RESULTSPATH/$TSTNAME.$BINNAME.$THREADS.$TIMELIMIT
OUTFILE=$BASENAME.out
RESFILE=$BASENAME.res
SOLFILE=$BASENAME.sol

# absolut tolerance for checking linear constraints and objective value
LINTOL=1e-4 
# absolut tolerance for checking integrality constraints 
INTTOL=1e-4 

# Note that the MIP gap (gap between primal and dual solution) is not
# uniqly defined through all solvers. For example, there is a difference
# between SCIP and CPLEX. All solver, however, have the some behaviour in
# case of a MIP gap of 0.0. 
MIPGAP=0.0

# post system information and current time into the output file
uname -a > $OUTFILE
date >> $OUTFILE

# convert hard memory limit to kilo bytes and post it into the output file
#HARDMEMLIMIT=`expr $HARDMEMLIMIT \* 1024`
#echo "hard mem limit: $HARDMEMLIMIT k" >> $OUTFILE

# loop over all instance names which are listed in the test set file name
for i in $TSTPATH/E/E-n13-k4 $TSTPATH/E/E-n22-k4 $TSTPATH/E/E-n23-k3 $TSTPATH/E/E-n30-k3 $TSTPATH/E/E-n31-k7 $TSTPATH/E/E-n33-k4 $TSTPATH/V/bayg-n29-k4 $TSTPATH/V/bays-n29-k5 $TSTPATH/V/ulysses-n16-k3 $TSTPATH/V/ulysses-n22-k4 $TSTPATH/V/gr-n17-k3 $TSTPATH/V/gr-n21-k3 $TSTPATH/V/gr-n24-k4 $TSTPATH/V/fri-n26-k3 $TSTPATH/V/swiss-n42-k5 $TSTPATH/V/gr-n48-k3 $TSTPATH/V/hk-n48-k $TSTPATH/V/att-n48-k4 $TSTPATH/E/E-n51-k5 $TSTPATH/A/A-n32-k5 $TSTPATH/A/A-n33-k5 $TSTPATH/A/A-n33-k6 $TSTPATH/A/A-n34-k5 $TSTPATH/A/A-n36-k5 $TSTPATH/A/A-n37-k5 $TSTPATH/A/A-n38-k5 $TSTPATH/A/A-n39-k5 $TSTPATH/A/A-n39-k6 $TSTPATH/A/A-n45-k6 $TSTPATH/A/A-n46-k7 $TSTPATH/B/B-n31-k5 $TSTPATH/B/B-n34-k5 $TSTPATH/B/B-n35-k5 $TSTPATH/B/B-n38-k6 $TSTPATH/B/B-n39-k5 $TSTPATH/B/B-n41-k6 $TSTPATH/B/B-n43-k6 $TSTPATH/B/B-n44-k7 $TSTPATH/B/B-n45-k5 $TSTPATH/B/B-n50-k7 $TSTPATH/B/B-n51-k7 $TSTPATH/B/B-n52-k7 $TSTPATH/B/B-n56-k7 $TSTPATH/B/B-n64-k9 $TSTPATH/A/A-n48-k7 $TSTPATH/A/A-n53-k7
do 
    # check if the current instance exists 
    if test -f $i
    then
        echo @01 $i ===========     
        echo -----------------------------
        date
        echo -----------------------------
        TIMESTART=`date +"%s"`
	echo @03 $TIMESTART
#	$SHELL -c " ulimit -v $HARDMEMLIMIT k; ulimit -f 2000000; $SCRIPTPATH/run_$SOLVER.sh $SOLVER $BINPATH/$BINNAME $i $TIMELIMIT $SOLFILE $THREADS $MIPGAP"
	$SHELL -c " $SCRIPTPATH/run_$SOLVER.sh $SOLVER $BINPATH/$BINNAME $i $TIMELIMIT $SOLFILE $THREADS $MIPGAP"
	echo 
        TIMEEND=`date +"%s"`
	echo @04 $TIMEEND
	echo @05 $TIMELIMIT
	# check if a solution file was written
	if test -e $OUTFILE
	then
	    # check if the link to the solution checker exists
	    if test -f "$CHECKERPATH/bin/solchecker" 
	    then
	    	echo 
	    	$SHELL -c " $CHECKERPATH/bin/solchecker $i $SOLFILE $LINTOL $INTTOL"  
	    	echo
	    else
		echo WARNING: solution cannot be checked because solution checker is missing 
	    fi 
	fi
        echo -----------------------------
        date
        echo -----------------------------
	echo
        echo =ready=
    else
        echo @02 FILE NOT FOUND: $i ===========
    fi
done 2>&1 | tee -a $OUTFILE

date >> $OUTFILE

if test -e sol.tmp
then
    rm sol.tmp
fi

awk -f $SCRIPTPATH/parse.awk -f  $SCRIPTPATH/parse_$SOLVER.awk $OUTFILE | tee $RESFILE

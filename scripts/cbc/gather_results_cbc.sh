#!/bin/bash

#* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#*                                                                           *
#*            This file is part of the test engine for MIPLIB2010            *
#*                                                                           *
#* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
# $Id: run.sh,v 1.4 2010/12/14 13:45:18 bzfheinz Exp $

# construct paths
POSTFIX=.2.6.parallel.miplib3.600
MIPLIBPATH=`pwd`
BINPATH=$MIPLIBPATH/bin
CHECKERPATH=$MIPLIBPATH/checker
RESULTSPATH=$MIPLIBPATH/results
SCRIPTPATH=$MIPLIBPATH/scripts
INSTPATH=$MIPLIBPATH/miplib3
OUTFILE=cbc.out$POSTFIX
RESFILE=cbc.res$POSTFIX

# absolute tolerance for checking linear constraints and objective value
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

# loop over all instance names which are listed in the test set file name
for i in $RESULTSPATH/*.out
do 
  instance_name=`basename ${i%.*}`
  echo @01 $instance_name ===========     
  echo -----------------------------
  date
  echo -----------------------------
  TIMESTART=`date +"%s"`
  echo @03 0.0
  cat ${RESULTSPATH}/${instance_name}.out
  
  echo 
#  TIMEEND=$TIMESTART+`fgrep -e "Wallclock" ${RESULTSPATH}/${instance_name}.out | cut --delimiter=" " --fields=4`
#  TIMEEND=$TIMESTART+`awk '/Wallclock/ {print $4}' ${RESULTSPATH}/${instance_name}.out` 
  echo @04 `awk '/Wallclock/ {print $4}' ${RESULTSPATH}/${instance_name}.out`
  echo @05 $TIMELIMIT
	# check if a solution file was written
  if test -e ${RESULTSPATH}/${instance_name}.sol
      then
	    # check if the link to the solution checker exists
      awk -f /home/ted/Cbc/trunk/Cbc/scripts/parse_cbc_sol.awk ${RESULTSPATH}/${instance_name}.sol > sol.tmp
      if test -f "$CHECKERPATH/bin/solchecker" 
	  then
	  echo 
	  $SHELL -c " $CHECKERPATH/bin/solchecker ${INSTPATH}/${instance_name}.gz sol.tmp $LINTOL $INTTOL"  
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
done 2>&1 | tee -a $OUTFILE

date >> $OUTFILE

if test -e sol.tmp
then
    rm sol.tmp
fi

awk -f $SCRIPTPATH/parse.awk -f  $SCRIPTPATH/parse_cbc.awk $OUTFILE | tee $RESFILE

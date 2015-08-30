#!/bin/bash

#* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#*                                                                           *
#*            This file is part of the test engine for MIPLIB2010            *
#*                                                                           *
#* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
# $Id: run.sh,v 1.4 2010/12/14 13:45:18 bzfheinz Exp $

# construct paths
PWD=`pwd`
CHECKERPATH=$PWD/checker
RESULTSPATH=$PWD/$1
SCRIPTPATH=$PWD/scripts
INSTPATH=$PWD/miplib3
OUTFILE=$RESULTSPATH/$1.output
RESFILE=$RESULTSPATH/$1.summary

# absolute tolerance for checking linear constraints and objective value
LINTOL=1e-4 
# absolut tolerance for checking integrality constraints 
INTTOL=1e-4 

# post system information and current time into the output file
uname -a > $OUTFILE
date >> $OUTFILE

# loop over all instance names which are listed in the test set file name
for i in $RESULTSPATH/*.out
do 
  instance_name=`basename ${i%.*}`
  #check whether this is one of the instances in the set
  if test -e ${INSTPATH}/${instance_name}.gz
  then 
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
      # write temporary solution file
      awk -f /home/ted/SYMPHONY/trunk/SYMPHONY/scripts/parse_symphony_sol.awk ${RESULTSPATH}/${instance_name}.out > sol.tmp
      # check if the link to the solution checker exists
      if test -f "$CHECKERPATH/bin/solchecker" 
      then
	  echo 
	  $SHELL -c " $CHECKERPATH/bin/solchecker ${INSTPATH}/${instance_name}.gz sol.tmp $LINTOL $INTTOL"  
	  echo
      else
	      echo WARNING: solution cannot be checked because solution checker is missing
      fi
      echo -----------------------------
      date
      echo -----------------------------
      echo
      echo =ready=
  fi
done 2>&1 | tee -a $OUTFILE

date >> $OUTFILE

if test -e sol.tmp
then
    rm sol.tmp
fi

awk -f $SCRIPTPATH/parse.awk -f  $SCRIPTPATH/symphony/parse_symphony.awk $OUTFILE | tee $RESFILE

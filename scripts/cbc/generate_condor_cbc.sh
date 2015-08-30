#!/bin/bash

TIMELIMIT=600
MIPGAP=0.0

MIPLIBPATH=`pwd`
BINPATH=$MIPLIBPATH/bin
CHECKERPATH=$MIPLIBPATH/checker
RESULTSPATH=$MIPLIBPATH/results
SCRIPTPATH=$MIPLIBPATH/scripts
TSTPATH=$MIPLIBPATH/testset
INSTPATH=$MIPLIBPATH/miplib3

UNIVERSE=vanilla
OUT_SUFF=".out"
ERR_SUFF=".err.\$(Process)"
VIS_SUFF=".vis"
SKEL_FILE=${SCRIPTPATH}/cbc.condor.skel
#EXECUTABLE=${SCRIPTPATH}/run_cbc.sh
EXECUTABLE=/home/ted/Cbc/stable/2.6/build-polyps-static-parallel/bin/cbc
EXEC_STATUS=`ls -lt ${EXECUTABLE}`
MAX_SECONDS=7800
HOLD=False

INIT_DIR=${INSTPATH}
LOG=${RESULTSPATH}/cbc.log

OUT_FILE=${BINPATH}/cbc.condor

cat $SKEL_FILE>$OUT_FILE
echo "
universe    = $UNIVERSE
log         = ${LOG}
Executable  = ${EXECUTABLE}
MAX_SECONDS = ${MAX_SECONDS}

# executable: ${EXEC_STATUS}

# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
">>$OUT_FILE


let count=0

for file in ${INSTPATH}/*.gz
#for instance_name in `awk '(1){print $1}' ${MIPLIBPATH}/benchmark.txt`
do
  instance_name=`basename ${file%.*}`
  if test ! -e ${RESULTSPATH}/${instance_name}.out
  then
      SOLFILE=${RESULTSPATH}/${instance_name}.sol
#     ARGS="cbc /home/tkr2/Cbc-trunk/build-static/bin/cbc $file $TIMELIMIT $SOLFILE 0 $MIPGAP"
      ARGS="-import $instance_name.gz -sec $TIMELIMIT -threads 4 -ratio $MIPGAP -timeMode elapsed -solve -solution $SOLFILE"
      echo "
      initialdir              = ${INIT_DIR}
      output                  = ${RESULTSPATH}/${instance_name}${OUT_SUFF}
      error                   = ${RESULTSPATH}/${instance_name}${ERR_SUFF}
      transfer_input_files    = ${INSTPATH}/${instance_name}.gz
      arguments               = ${ARGS}
      hold                    = $HOLD
      should_transfer_files   = yes
      when_to_transfer_output = ON_EXIT
      queue 1
      
# -----------------------------------------------------------------------------
      ">>$OUT_FILE
      echo -n "."
      let count=$count+1
  fi
done
echo
echo "$OUT_FILE has $count jobs."

#!/bin/bash

CPUS=$1
TIMELIMIT=$2
POSTFIX=$3

PWD=`pwd`
JOBPATH=$PWD/jobs
CHECKERPATH=$PWD/checker
RESULTSPATH=$PWD/dip/res.$CPUS.$TIMELIMIT.$POSTFIX
SCRIPTPATH=$PWD/scripts
INSTPATH=$PWD/decomplib

UNIVERSE=vanilla
OUT_SUFF=".out"
ERR_SUFF=".err.\$(Process)"
VIS_SUFF=".vis"
SKEL_FILE=${JOBPATH}/dip.condor.skel
#EXECUTABLE=${SCRIPTPATH}/run_cbc.sh
#EXECUTABLE=/home/ted/COIN/Dip-trunk/build-debug-cplex/bin/dip
EXECUTABLE=/home/ted/COIN/Dip-trunk/build-debug-sym/bin/dip
#EXECUTABLE=/home/ted/COIN/Dip-trunk/build-debug/bin/dip
#EXECUTABLE=/home/ted/COIN/Dip-trunk/build-grb/bin/dip
EXEC_STATUS=`ls -lt ${EXECUTABLE}`
HOLD=False

INIT_DIR=${INSTPATH}
LOG=${RESULTSPATH}/dip.log

OUT_FILE=${JOBPATH}/dip.condor

cat $SKEL_FILE>$OUT_FILE
echo "
universe    = $UNIVERSE
log         = ${LOG}
Executable  = ${EXECUTABLE}

# executable: ${EXEC_STATUS}

# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
">>$OUT_FILE

mkdir -p $RESULTSPATH

let count=0

BLOCKEXT=dec
FILEEXT=mps

for file in ${INSTPATH}/*.${FILEEXT}
#for instance_name in `awk '(1){print $1}' ${MIPLIBPATH}/benchmark.txt`
do
  instance_name=`basename ${file%.*}`
  if test ! -e ${RESULTSPATH}/${instance_name}.out
  then
      SOLFILE=${RESULTSPATH}/${instance_name}.sol
      block='.dec' 
#     ARGS="cbc /home/tkr2/Cbc-trunk/build-static/bin/cbc $file $TIMELIMIT $SOLFILE 0 $MIPGAP"
#      ARGS="-F $instance_name.gz -t $TIMELIMIT -p $CPUS -f options.txt --args"
      ARGS="--TimeLimit $TIMELIMIT --SolutionOutputFileName $SOLFILE --Instance ${instance_name}.${FILEEXT} --BlockFile ${instance_name}.${BLOCKEXT} --NumConcurrentThreadsSubProb ${CPUS}"
      echo "
      initialdir              = ${INIT_DIR}
      output                  = ${RESULTSPATH}/${instance_name}${OUT_SUFF}
      error                   = ${RESULTSPATH}/${instance_name}${ERR_SUFF}
      transfer_input_files    = ${INSTPATH}/${instance_name}.${FILEEXT},${INSTPATH}/${instance_name}.${BLOCKEXT}
      arguments               = ${ARGS}
      hold                    = $HOLD
      should_transfer_files   = yes
      when_to_transfer_output = ON_EXIT
      request_cpus            = $CPUS
      queue 1
      
# -----------------------------------------------------------------------------
      ">>$OUT_FILE
      echo -n "."
      let count=$count+1
  fi
done
echo
echo "$OUT_FILE has $count jobs."

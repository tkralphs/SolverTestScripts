#!/bin/bash

TIMELIMIT=$1
CPUS=$2
POSTFIX=$3

PWD=`pwd`
JOBPATH=$PWD/jobs
RESULTSPATH=$PWD/mibs/mibs.res.$TIMELIMIT.$CPUS.$POSTFIX
SCRIPTPATH=$PWD/scripts
#INSTPATH=/home/ted/COIN/MibS/data/MCDM/NO_CORR/50_ITEMS_1000
#INSTPATH=/home/ted/COIN/MibS/data/ASSIGNMENT
INSTPATH=/home/ted/COIN/MibS/data/MIPS/RANDOM/NEW_MIPINT/

UNIVERSE=vanilla
OUT_SUFF=".out"
ERR_SUFF=".err.\$(Process)"
VIS_SUFF=".vis"
SKEL_FILE=${JOBPATH}/mibs.condor.skel
#EXECUTABLE=${SCRIPTPATH}/run_cbc.sh
EXECUTABLE=/home/ted/COIN/MibS/mibs
EXEC_STATUS=`ls -lt ${EXECUTABLE}`
HOLD=False

INIT_DIR=${INSTPATH}
LOG=${RESULTSPATH}/mibs.log

OUT_FILE=${JOBPATH}/mibs.condor

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

cp jobs/mibs.par jobs/mibs.par.$TIMELIMIT.$CPUS.$POSTFIX

let count=0

for file in ${INSTPATH}/*.mps
#for instance_name in `awk '(1){print $1}' ${MIPLIBPATH}/benchmark.txt`
do
  instance_name=`basename ${file%.*}`
  if test ! -e ${RESULTSPATH}/${instance_name}.out
  then
      ARGS="-Alps_instance ${instance_name}.mps -MibS_auxiliaryInfoFile ${instance_name}.mps.txt -Alps_timeLimit ${TIMELIMIT} -MibS_maxThreadsLL $CPUS -param mibs.par.$TIMELIMIT.$CPUS.$POSTFIX"
      echo "
      initialdir              = ${INIT_DIR}
      output                  = ${RESULTSPATH}/${instance_name}${OUT_SUFF}
      error                   = ${RESULTSPATH}/${instance_name}${ERR_SUFF}
      transfer_input_files    = ${INSTPATH}/${instance_name}.mps,${INSTPATH}/NONSYMMETRIC/${instance_name}.mps.txt,${JOBPATH}/mibs.par.$TIMELIMIT.$CPUS.$POSTFIX
      arguments               = ${ARGS}
      hold                    = $HOLD
      should_transfer_files   = yes
      when_to_transfer_output = ON_EXIT
      request_cpus            = `expr $CPUS`
      queue 1
      
# -----------------------------------------------------------------------------
      ">>$OUT_FILE
      echo -n "."
      let count=$count+1
  fi
done
echo
echo "$OUT_FILE has $count jobs."

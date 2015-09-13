#!/bin/bash

CPUS=$1
TIMELIMIT=$2
POSTFIX=$3
MIPGAP=0.0

PWD=`pwd`
JOBPATH=$PWD/jobs
CHECKERPATH=$PWD/checker
RESULTSPATH=$PWD/cbc/res.$CPUS.$TIMELIMIT.$POSTFIX
SCRIPTPATH=$PWD/scripts
INSTPATH=$PWD/miplib2010

UNIVERSE=vanilla
OUT_SUFF=".out"
ERR_SUFF=".err.\$(Process)"
VIS_SUFF=".vis"
SKEL_FILE=${SCRIPTPATH}/cbc/cbc.condor.skel
#EXECUTABLE=${SCRIPTPATH}/run_cbc.sh
EXECUTABLE=/home/ted/COIN/trunk/build-polyps-parallel/bin/cbc
EXEC_STATUS=`ls -lt ${EXECUTABLE}`
HOLD=False

INIT_DIR=${INSTPATH}
LOG=${RESULTSPATH}/cbc.log

OUT_FILE=${JOBPATH}/cbc.condor

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

#for file in ${INSTPATH}/*.gz
for file in `awk '(1){print $1}' ${INSTPATH}/miplib2010_bench.test`
do
  instance_name=`basename ${file%.*}`
  if test ! -e ${RESULTSPATH}/${instance_name}.out
  then
      SOLFILE=${RESULTSPATH}/${instance_name}.sol
#     ARGS="cbc /home/tkr2/Cbc-trunk/build-static/bin/cbc $file $TIMELIMIT $SOLFILE 0 $MIPGAP"
      ARGS="-import $instance_name.gz -sec $TIMELIMIT -threads $CPUS -ratio $MIPGAP -timeMode elapsed -solve -solution $SOLFILE"
      echo "
      initialdir              = ${INIT_DIR}
      output                  = ${RESULTSPATH}/${instance_name}${OUT_SUFF}
      error                   = ${RESULTSPATH}/${instance_name}${ERR_SUFF}
      transfer_input_files    = ${INSTPATH}/${instance_name}.gz
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

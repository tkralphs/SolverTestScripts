#!/bin/bash

CPUS=$1
TIMELIMIT=$2
POSTFIX=$3

PWD=`pwd`
JOBPATH=$PWD/jobs
CHECKERPATH=$PWD/checker
RESULTSPATH=$PWD/symphony/res.$CPUS.$TIMELIMIT.$POSTFIX
SCRIPTPATH=$PWD/scripts
INSTPATH=$PWD/miplib2010

UNIVERSE=vanilla
OUT_SUFF=".out"
ERR_SUFF=".err.\$(Process)"
VIS_SUFF=".vis"
SKEL_FILE=${JOBPATH}/symphony.condor.skel
#EXECUTABLE=${SCRIPTPATH}/run_cbc.sh
EXECUTABLE=/home/ted/COIN/trunk/build-linux-x86_64-gcc4.7.2/bin/symphony
EXEC_STATUS=`ls -lt ${EXECUTABLE}`
HOLD=False

INIT_DIR=${INSTPATH}
LOG=${RESULTSPATH}/symphony.log

OUT_FILE=${JOBPATH}/symphony.condor

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
      ARGS="-F $instance_name.gz -t $TIMELIMIT -p $CPUS --args"
      echo "
      initialdir              = ${INIT_DIR}
      output                  = ${RESULTSPATH}/${instance_name}${OUT_SUFF}
      error                   = ${RESULTSPATH}/${instance_name}${ERR_SUFF}
      transfer_input_files    = ${INSTPATH}/${instance_name}.gz,${JOBPATH}/options.txt
      arguments               = ${ARGS}
      hold                    = $HOLD
      should_transfer_files   = yes
      when_to_transfer_output = ON_EXIT
      request_cpus            = `expr $CPUS + 1`
      queue 1
      
# -----------------------------------------------------------------------------
      ">>$OUT_FILE
      echo -n "."
      let count=$count+1
  fi
done
echo
echo "$OUT_FILE has $count jobs."

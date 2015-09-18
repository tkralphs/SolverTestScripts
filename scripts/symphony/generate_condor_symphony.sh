#!/bin/bash

CPUS=$1
TIMELIMIT=$2
ADDITIONAL_ARGS=$3
SUFFIX_STR=$4

PWD=`pwd`
JOBPATH=$PWD/jobs
CHECKERPATH=$PWD/checker
SCRIPTPATH=$PWD/scripts
INSTPATH=$PWD/miplib3
TESTSET=`basename $INSTPATH`
EXECUTABLE=/home/ted/COIN/SYMPHONY-trunk/build-opt/bin/symphony
EXEC_STATUS=`ls -lt ${EXECUTABLE}`
REVISION=`$EXECUTABLE --version | awk '($2 == "Revision") {print $4;}'`
VERSION=`$EXECUTABLE --version | awk '($2 == "Version:") {print $3;}'`
echo "$3"
ARGS=`echo "$3" | sed 's/ //g'`
echo $ARGS
SUFFIX=$CPUS.$TIMELIMIT
if [ -n "$3" ] 
then
  SUFFIX+=.$ARGS
fi
if [ -n "$4" ]
then
  SUFFIX+=.$SUFFIX_STR
fi
SUFFIX+=.$VERSION.R$REVISION.$TESTSET
RESULTSPATH=$PWD/symphony/res.$SUFFIX

UNIVERSE=vanilla
OUT_SUFF=".out"
ERR_SUFF=".err.\$(Process)"
VIS_SUFF=".vis"
SKEL_FILE=${JOBPATH}/symphony.condor.skel
#EXECUTABLE=${SCRIPTPATH}/run_cbc.sh
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

for file in ${INSTPATH}/*.gz
#for file in `awk '(1){print $1}' ${INSTPATH}/miplib2010_bench.test`
do
  instance_name=`basename ${file%.*}`
  if test ! -e ${RESULTSPATH}/${instance_name}.out
  then
      SOLFILE=${RESULTSPATH}/${instance_name}.sol
#     ARGS="cbc /home/tkr2/Cbc-trunk/build-static/bin/cbc $file $TIMELIMIT $SOLFILE 0 $MIPGAP"
      ARGS="-F $instance_name.gz -t $TIMELIMIT -p $CPUS $ADDITIONAL_ARGS --args"
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

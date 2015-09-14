#!/bin/bash

TIME_LIMIT=3600
X_LIMIT=4
FILES= 
for dir in "$@"; do
   exp=`basename $dir`
   awk -f scripts/pprof.awk $dir/$exp.summary > $dir/$exp.pprof 
   FILES+=$dir/$exp.pprof
   FILES+=" "
done
python scripts/pprof.py -c 2 -l 2 --max-limit=$TIME_LIMIT --x-limit=$X_LIMIT $FILES > compare.eps

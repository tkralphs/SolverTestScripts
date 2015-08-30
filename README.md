MIP Solver Test Scripts

This is a small collection of scripts for testing of MILP solvers. 
It is a slight modification and extension of the very nice test harness 
available with the MIPLIB 2010 test suite, downloadable here:

http://miplib.zib.de/download/miplib2010-1.1.1-script.tgz

It includes not only scripts for doing sequential testing on a 
single compute node, but also scripts for generating condor submit
files, running jobs in parallel, and collecting results afterwards.
The condor capabilities required splitting the original MIPLIB
scripts into two pieces. The first step in using any of the scripts
is to build the solution checker in the ```checker``` folder.

After building the checker, to use the scripts in the their original
mode on a single local compute node, edit ```scripts/run.sh``` to reflect 
the name of the solver to be tested and make sure that the paths to
various directories are correct. Then simply execute the script with no
arguments.

To use the scripts in the condor mode, first modify the file
```scripts/xxx/generate_condor_xxx.sh```, where ```xxx``` is the name of 
the solver to be tested. Primarily, it is necessary to specify a path
to the solver executable. Then run the scripts as
```
scripts/xxx/generate_condor_xxx.sh NumCores TimeLimit PostFix
```
from the root of the checkout, where ```NumCores``` is the number of cores 
to be used for parallel runs, ```TimeLimit``` is the desired time limit for 
the run, and ```PostFix``` is an additional arbitrary string to be added to 
the name of the results directory that can be used to indicate a version 
number or special parameters. For example
```
scripts/symphony/generate_condor_symphony 1 3600 trunk
```
will run jobs on a single core for one hour and put results in the 
directory ```symphony/res.1.3600.trunk```. The result of running the script 
will be a condor submission file. Submit it to condor with
```
condor_submit jobs/xxx.condor
```
When all jobs are finished the results can be gathered and checked by
running
```
scripts/xxx/gather_results_xxx.sh DirName
```
where ```DirName``` is the complete name of the directory name where
the results are located (```res.1.3600.trunk``` in the example).

This is a work in progress and your mileage may vary. There may be
mistakes in the scripts and/or documentation so use at your own risk!

-Ted
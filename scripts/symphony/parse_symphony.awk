#!/usr/bin/awk -f
#* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#*                                                                           *
#*            This file is part of the test engine for MIPLIB2010            *
#*                                                                           *
#* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

# set all solver specific data:
#  solver ["?"]
#  solverversion ["?"]
#  lps ["none"]
#  lpsversion ["-"]
#  bbnodes [0]
#  db [-infty]
#  pb [+infty]
#  aborted [1]
#  timeout [0]

# The solver name
BEGIN {
   solver = "SYMPHONY";
   gap = 1;
}

# The solver version 
/Version:/ { 
   version = $3; 
}

/Revision Number:/ {
   revision = $4;
   solverversion = version "-" revision
}

# The results
/Optimal/ {
   if ($2 == "Optimal"){
      aborted = 0;
      timeout = 0;
      gap = 0;
   }
}

/Time/ {
   if ($2 == "Time"){
       timeout = 1;
       aborted = 0;
       gap = 1;
   }
}

/abnormally/ {
   if ($6 == "abnormally"){
       timeout = 1;
       aborted = 0;
       gap = 1;
   }
}

/Terminated/ {
   aborted = 1
   gap = 1;
}

/infeasible/ {
   pb = +infty;
   db = +infty;
   aborted = 0;
   timeout = 0;
   gap = 1;
}

/unbounded/ {
   pb = -infty;
   db = -infty;
   aborted = 0;
   timeout = 0;
   gap = 1;
}

/No Solution/ {
   aborted = 0;
   pb = +infty;
   gap = 1;
}

/Solution Cost/{
   aborted = 0;
   if (!gap){
      pb = db = $3;
   }
}

/Current Upper Bound:/ {
   aborted = 0;
   pb = $4;
   gap = 1;
}

/Current Lower Bound:/ {
   aborted = 0;
   db = $4;
   gap = 1;
}

/analyzed nodes:/ {
   bbnodes = $5;
   aborted = 0;
}

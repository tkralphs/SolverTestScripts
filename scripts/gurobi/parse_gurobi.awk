#!/usr/bin/awk -f
#* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#*                                                                           *
#*            This file is part of the test engine for MIPLIB2010            *
#*                                                                           *
#* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
# $Id: parse_gurobi.awk,v 1.1 2010/12/09 22:22:28 bzfheinz Exp $


# set all solver specific data:
#  solver ["?"]
#  solverversion ["?"]
#  solverremark [""]
#  bbnodes [0]
#  db [-infty]
#  pb [+infty]
#  aborted [1]
#  timeout [0]

BEGIN {
  solver = "Gurobi";
}
# solver version
/^Gurobi Optimizer version/ { solverversion = $4; }
# branch and bound nodes
/^Explored/ { bbnodes = $2; }
# dual and primal bound
/^Best objective/ {
 pb = $3 + 0.0;
 db = $6 + 0.0;
}
# solving status
/^Explored/ { aborted = 0; }
/^Time limit reached/ { timeout = 1; }


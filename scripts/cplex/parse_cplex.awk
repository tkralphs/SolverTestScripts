#!/usr/bin/awk -f
#* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#*                                                                           *
#*            This file is part of the test engine for MIPLIB2010            *
#*                                                                           *
#* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
# $Id: parse_cplex.awk,v 1.1 2010/12/09 22:22:28 bzfheinz Exp $


# set all solver specific data:
#  solver ["?"]
#  solverversion ["?"]
#  solverremark [""]
#  bbnodes [0]
#  db [-infty]
#  pb [+infty]
#  aborted [1]
#  timeout [0]

# solver name
BEGIN {
   solver = "CPLEX";
   solverremark = "";
   solver_objsense = +1;
   solver_type = "MIP";
}
# solver version 
/^Welcome to.* Interactive Optimizer/ { solverversion = $NF; }

# objective sense
/^Problem is a minimization problem./ {
   solver_objsense = +1;
}
/^Problem is a maximization problem./ {
   solver_objsense = -1;
}

# branch and bound nodes
/^Solution time/ {
   bbnodes = $11;
   aborted = 0;
}

# dual and primal bound, and solving status
/^MIP - / { solver_type = $1; $0 = substr($0, 7, length($0)-6); }
/^Barrier - / { solver_type = $1; $0 = substr($0, 11, length($0)-10); }
/^Primal simplex - / { solver_type = $1; $0 = substr($0, 18, length($0)-17); }
/^Dual simplex - / { solver_type = $1; $0 = substr($0, 16, length($0)-15); }
/^Populate - / { solver_type = "MIP"; $0 = substr($0, 12, length($0)-11); }
/^Presolve - / { solver_type = $1; $0 = substr($0, 12, length($0)-11); }
/^Integer /  {
   if ($2 ~ /infeasible/ )
   {
      db = solver_objsense * infty;
      pb = solver_objsense * infty;
   }
   else
   {
      db = $NF;
      pb = $NF;
   }
   timeout = 0;
}
/^Optimal:  Objective = / {
   pb = $NF;
   db = $NF;
   timeout = 0;
}
/^Non-optimal:  Objective = / {
   pb = $NF;
   db = $NF;
   timeout = 0;
}
/^Unbounded or infeasible./ {
   db = solver_objsense * infty;
   pb = solver_objsense * infty;
   timeout = 0;
}
/^Infeasible/ {
   db = solver_objsense * infty;
   pb = solver_objsense * infty;
   timeout = 0;
}
/^Unbounded/ {
   db = solver_objsense * infty;
   pb = solver_objsense * infty;
   timeout = 0;
}
/^Dual objective limit exceeded/ {
   db = solver_objsense * infty;
   pb = solver_objsense * infty;
   timeout = 0;
}
/^Primal objective limit exceeded/ {
   db = solver_objsense * infty;
   pb = solver_objsense * infty;
   timeout = 0;
}
/^Solution limit exceeded/ {
   pb = $NF;
   timeout = 0;
}
/^Time limit exceeded/  {
   pb = solver_objsense * infty;
   if ( solver_type == "MIP" && $4 != "no" )
      pb = $8;
   timeout = 1;
}
/^Memory limit exceeded/ {
   pb = solver_objsense * infty;
   if ( solver_type == "MIP" && $4 != "no" )
      pb = $8;
   timeout = 1;
}
/^Node limit exceeded/ {
   pb = ($4 == "no") ? solver_objsense * infty : $8;
   timeout = 1;
}
/^Tree /  {
   pb = ($4 == "no") ? solver_objsense * infty : $8;
   timeout = 1;
}
/^Aborted, / {
   pb = solver_objsense * infty;
   if ( solver_type == "MIP" && $2 != "no" )
      pb = $6;
   timeout = 0;
   aborted = 1;
}
/^Error /  {
   pb = solver_objsense * infty;
   if ( solver_type == "MIP" && $3 != "no" )
      pb = $7;
   timeout = 0;
   aborted = 1;
}
/^Unknown status / {
   pb = solver_objsense * infty;
   if ( solver_type == "MIP" && $4 == "Objective" )
      pb = $6;
   timeout = 0;
}
/^All reachable solutions enumerated, integer / {
   if ($6 ~ /infeasible/ )
   {
      db = solver_objsense * infty;
      pb = solver_objsense * infty;
   }
   else
   {
      db = $NF;
      pb = $NF;
   }
   timeout = 0;
}
/^Populate solution limit exceeded/ {
   pb = $NF;
   timeout = 0;
}
/^Current MIP best bound =/ {
   db = $6;
}

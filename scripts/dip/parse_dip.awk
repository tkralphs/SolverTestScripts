#!/usr/bin/awk -f
#* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#*                                                                           *
#*            This file is part of the test engine for MIPLIB2010            *
#*                                                                           *
#* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
# $Id: parse_cplex.awk,v 1.4 2011/04/01 16:55:27 bzfgamra Exp $


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
   solver = "DIP";
   solverremark = "test on decomplib";   
}

# The solver version
/^Version:/ { 
    version = $2;
}

/^Revision Number:/ {
    revision = $3; 
    solverversion = version "-" revision
}

# The results
/^Status/ {
    if ($3 == "Optimal"){

	aborted = 0; 
	timeout = 0; 
    }
    else if ($3 == "TimeLimit"){
	timeout = 1; 
	aborted = 0; 
    }
    else if ($3 == "NodeLimit"){
	timeout = 1; 
	aborted = 0; 
    }

    else if ($3 == "Infeasible"){
	pb = +infty; 
	db = +infty; 
	aborted = 0; 
	timeout = 0; 
    }

    else if ($3 == "Unbounded"){
	pb = -infty; 
	db = -infty; 
	aborted = 0; 
	timeout = 0; 
    }
    else if ($3 == "Failed"){
	aborted = 1;
    }
    else if ($3 == "Unknown"){
	aborted = 1; 
    }

    else if ($3 == "NoMemory"){
	aborted = 1; 
    }
    
}

/^BestLB/{
    db = $3; 
}

/^BestUB/{

    pb = $3;
}


/^Nodes/ {
    bbnodes = $3;
}

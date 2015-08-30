/**
 * @file main.cpp
 * @brief Solution Checker main file
 *
 * @author Domenico Salvagnin
 */

#include "model.h"
#include "mpsinput.h"
#include "gmputils.h"

#include <stdlib.h>
#include <iostream>

void usage()
{
   std::cout << "Usage: solchecker filename.mps[.gz] solution.sol [linear_tol int_tol]" << std::endl;
}

int main (int argc, char const *argv[])
{
   if( argc < 3 )
   {
      usage();
      return -1;
   }

   // read model
   Model* model = new Model;
   MpsInput* mpsi = new MpsInput;
   
   bool success = mpsi->readMps(argv[1], model);
   std::cout << "Read MPS: " << success << std::endl;
   if( !success ) return -1;
   
   std::cout << "MIP has " << model->numVars() << " vars and " << model->numConss() << " constraints" << std::endl;

   // read solution
   success = model->readSol(argv[2]);
   std::cout << "Read SOL: " << success << std::endl;
   if( !success ) return -1;
   
   // read tolerances
   Rational linearTolerance(1, 10000);
   if( argc > 3 ) linearTolerance.fromString(argv[3]);
   Rational intTolerance(linearTolerance);
   if( argc > 4 ) intTolerance.fromString(argv[4]);
   
   std::cout << "Integrality tolerance: " << intTolerance.toString() << std::endl;
   std::cout << "Linear tolerance: " << linearTolerance.toString() << std::endl;
   std::cout << "Objective tolerance: " << linearTolerance.toString() << std::endl;
   
   // check!
   bool intFeas;
   bool linFeas;
   bool obj;
   model->check(intTolerance, linearTolerance, intFeas, linFeas, obj);
   
   std::cout << "Check SOL: Integrality " << intFeas 
      << " Constraints " << linFeas
      << " Objective " << obj << std::endl;
   
   // clean up
   delete mpsi;
   delete model;

   return 0;
}

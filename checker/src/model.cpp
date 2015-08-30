/**
 * @file model.cpp
 * @brief Basic classes to describe a MIP model
 *
 * @author Domenico Salvagnin
 */

#include "model.h"
#include "string.h"
#include <assert.h>

#include <iostream>

#define SOL_MAX_LINELEN 1024
#define BLANK           ' '

Var::Var(const char* _name, VarType _type, const Rational& _lb, const Rational& _ub, const Rational& _obj)
   : name(_name), type(_type), lb(_lb), ub(_ub), objCoef(_obj) {}

bool Var::checkBounds(const Rational& boundTolerance) const
{
   Rational relaxedLb(lb);
   relaxedLb -= boundTolerance; 
   Rational relaxedUb(ub);
   relaxedUb += boundTolerance; 
   if( (value < relaxedLb) || (value > relaxedUb) )
   {
      std::cerr << "Failed bound check: ";
      print(std::cerr);
      std::cerr << std::endl;
      return false;
   }
   return true;
}

bool Var::checkIntegrality(const Rational& intTolerance) const
{
   if( (type != CONTINUOUS) && !value.isInteger(intTolerance) )
   {
      std::cerr << "Failed integrality check: ";
      print(std::cerr);
      std::cerr << std::endl;
      return false;
   }
   return true;
}

void Var::print(std::ostream& out) const
{
   out << name << " [" << lb.toString() << "," << ub.toString() << "] ";
   switch(type)
   {
      case BINARY:
         out << "binary";
         break;
      case INTEGER:
         out << "integer";
         break;
      case CONTINUOUS:
         out << "continuous";
         break;
      default:
         out << "(unknown)";
   }
   out << ". Value: " << value.toString(); 
}

Constraint::Constraint(const char* _name, bool _redundant)
   : name(_name), type("<unknown>"), redundant(_redundant) {}

LinearConstraint::LinearConstraint(const char* _name, LinearType _lintype, const Rational& _lhs, const Rational& _rhs, bool _redundant)
   : Constraint(_name, _redundant), lintype(_lintype), lhs(_lhs), rhs(_rhs)
{
   type = "<linear>";
}

void LinearConstraint::push(Var* v, const Rational& c)
{
   vars.push_back(v);
   coefs.push_back(c);
}

bool LinearConstraint::check(const Rational& tolerance) const
{
   // compute row activity
   Rational relaxedLhs(lhs);
   relaxedLhs -= tolerance; 
   Rational relaxedRhs(rhs);
   relaxedRhs += tolerance;
   Rational activity;
   for( unsigned int i = 0; i < vars.size(); ++i )
      activity.addProduct(coefs[i], vars[i]->value);
   // check lhs and rhs
   if (activity < relaxedLhs || activity > relaxedRhs)
   {
      std::cerr << "Failed check for cons " << name << ": "
                << activity.toDouble() << " not in [" << relaxedLhs.toDouble() << "," << relaxedRhs.toDouble() << "] -- Exact wrt linear tol: " 
                << activity.toString() << " not in [" << relaxedLhs.toString() << "," << relaxedRhs.toString() << "]" 
                << std::endl;
      return false;
   }
   return true;
}

void LinearConstraint::print(std::ostream& out) const
{
   out << name << " " << type << ": " << lhs.toString() << " <= ";
   for( unsigned int i = 0; i < vars.size(); ++i )
   {
      out << coefs[i].toString() << " " << vars[i]->name << " ";
   }
   out << "<= " << rhs.toString();
}

SOSConstraint::SOSConstraint(const char* _name, SOSType _sostype, bool _redundant)
   : Constraint(_name, _redundant), sostype(_sostype)
{
   type = "<SOS>";
}

void SOSConstraint::push(Var* v)
{
   vars.push_back(v);
}

bool SOSConstraint::check(const Rational& tolerance) const
{
   switch(sostype)
   {
   case TYPE_1:
      return checkType1(tolerance);
   case TYPE_2:
      return checkType2(tolerance);
   default :
      return false;
   }
   return false;
}

void SOSConstraint::print(std::ostream& out) const
{
   out << name << " " << type;
   if( sostype == TYPE_1 ) out << " 1: ";
   else if( sostype == TYPE_2 ) out << " 2: ";
   for( unsigned int i = 0; i < vars.size(); ++i )
   {
      out << vars[i]->name << " ";
   }
}

bool SOSConstraint::checkType1(const Rational& tolerance) const
{
   int cnt = 0;
   Rational lb;
   Rational ub;
   lb -= tolerance;
   ub += tolerance;
   // count number of non-zero variables
   for( unsigned int i = 0; i < vars.size(); ++i )
   {
      if((vars[i]->value < lb) || (vars[i]->value > ub))
         cnt++;
   }
   return (cnt <= 1);
}

bool SOSConstraint::checkType2(const Rational& tolerance) const
{
   int cnt = 0;
   Rational lb;
   Rational ub;
   lb -= tolerance;
   ub += tolerance;
   const unsigned int noIndex = -1;
   unsigned int firstIndex = noIndex;
   // count number of non-zero variables
   for( unsigned int i = 0; i < vars.size(); ++i )
   {
      if((vars[i]->value < lb) || (vars[i]->value > ub))
      {
         cnt++;
         if( firstIndex == noIndex)
            firstIndex = i;
      }
   }
   if( cnt > 2 )
      return false;
   if( cnt < 2 )
      return true;
   // check if var in position (firstIndex + 1) is non-zero
   if((vars[firstIndex + 1]->value < lb) || (vars[firstIndex + 1]->value > ub))
      return true;
   return false;
}

Model::Model() : objSense(MINIMIZE), hasObjectiveValue(false) {}

Model::~Model()
{
   // delete constraints
   std::map<std::string, Constraint*>::iterator citr = conss.begin();
   std::map<std::string, Constraint*>::iterator cend = conss.end();
   while( citr != cend )
   {
      delete citr->second;
      ++citr;
   }
   conss.clear();
   
   // delete vars
   std::map<std::string, Var*>::iterator vitr = vars.begin();
   std::map<std::string, Var*>::iterator vend = vars.end();
   while( vitr != vend )
   {
      delete vitr->second;
      ++vitr;
   }
   vars.clear();
}

Var* Model::getVar(const char* name) const
{
   std::map<std::string, Var*>::const_iterator itr = vars.find(name);
   if( itr != vars.end() ) return itr->second;
   return NULL;
}

Constraint* Model::getCons(const char* name) const
{
   std::map<std::string, Constraint*>::const_iterator itr = conss.find(name);
   if( itr != conss.end() ) return itr->second;
   return NULL;
}

void Model::pushVar(Var* var)
{
   assert ( var != NULL );
   vars[var->name] = var;
}

void Model::pushCons(Constraint* cons)
{
   assert ( cons != NULL );
   conss[cons->name] = cons;
}

unsigned int Model::numVars() const
{
   return vars.size();
}
   
unsigned int Model::numConss() const
{
   return conss.size();
}
   
bool Model::readSol(const char* filename)
{
   assert( filename != NULL );
   char buf[SOL_MAX_LINELEN];
   
   FILE* fp = fopen(filename, "r");
   if( fp == NULL )
   {
      std::cerr << "cannot open file <" << filename << "> for reading" << std::endl;
      return false;
   }
   
   hasObjectiveValue = false;
   bool hasVarValue = false;
   bool isSolFeas = true;

   while(true)
   {
      // clear buffer content
      memset((void*)buf, 0, SOL_MAX_LINELEN);
      if (NULL == fgets(buf, sizeof(buf), fp))
         break;
      
      // Normalize white spaces in line
      unsigned int len = strlen(buf);
      for( unsigned int i = 0; i < len; i++ )
         if( (buf[i] == '\t') || (buf[i] == '\n') || (buf[i] == '\r') )
            buf[i] = BLANK;
      
      // tokenize
      char* nexttok;
      const char* varname = strtok_r(&buf[0], " ", &nexttok);
      if( varname == NULL )
         continue;

      if( strcmp(varname, "=infeas=") == 0 )
      {
         isSolFeas = false;
         break;
      }

      const char* valuep = strtok_r(NULL, " ", &nexttok);
      assert( valuep != NULL );

      if( strcmp(varname, "=obj=") == 0 )
      {
         // read objective value
         hasObjectiveValue = true;
         objectiveValue.fromString(valuep); 
      }
      else
      {
         // read variable value
         Var* var = getVar(varname);
         if( var == NULL ) std::cerr << "unexpected variable<" << varname << "> in solution file" << std::endl;
         assert( var != NULL );
         Rational value;
         value.fromString(valuep);
         var->value = value;
         hasVarValue = true;
      }
   }
   isSolFeas = isSolFeas && hasVarValue;
   
   fclose(fp);
   fp = NULL;

   return isSolFeas;
}

void Model::check(
   const Rational& intTolerance,
   const Rational& linearTolerance,
   bool& intFeasible,
   bool& linearFeasible,
   bool& correctObj) const
{
   // check vars first
   intFeasible = true;
   linearFeasible = true;
   std::map<std::string, Var*>::const_iterator vitr = vars.begin();
   std::map<std::string, Var*>::const_iterator vend = vars.end();
   while( vitr != vend && intFeasible && linearFeasible )
   {
      linearFeasible &= vitr->second->checkBounds(linearTolerance);
      intFeasible &= vitr->second->checkIntegrality(intTolerance);
      ++vitr;
   }
   
   // then check constraints
   std::map<std::string, Constraint*>::const_iterator citr = conss.begin();
   std::map<std::string, Constraint*>::const_iterator cend = conss.end();
   while( citr != cend && linearFeasible )
   {
      linearFeasible &= citr->second->check(linearTolerance);
      ++citr;
   }

   correctObj = true;
   // then check objective function
   if( hasObjectiveValue )
   {
      Rational objVal;

      vitr = vars.begin();
      while( vitr != vend )
      {
         objVal.addProduct(vitr->second->objCoef, vitr->second->value);
         ++vitr;
      }
      Rational diff;
      sub(diff, objVal, objectiveValue);
      diff.abs();
      if( diff > linearTolerance )
      {
         std::cerr << "Failed objective value check: " 
                   << objectiveValue.toDouble() << " != " << objVal.toDouble() << " -- Exact absolut diff: "  
                   << diff.toString() << " > " << linearTolerance.toString() 
                   << std::endl;
         correctObj = false;
      }
   }
   else
   {
      std::cerr << "Failed objective value check: No objective value given" 
                << std::endl;
      correctObj = false;
   }
}

void Model::print(std::ostream& out) const
{
   out << "Model: " << modelName << std::endl;
   if( objSense == MINIMIZE )
      out << "Minimize ";
   else if( objSense == MAXIMIZE )
      out << "Maximize ";
      
   out << objName << ": ";
   std::map<std::string, Var*>::const_iterator vitr = vars.begin();
   std::map<std::string, Var*>::const_iterator vend = vars.end();
   while( vitr != vend )
   {
      out << vitr->second->objCoef.toString() << " " << vitr->second->name << " ";
      ++vitr;
   }
   out << std::endl;
   
   out << "s.t." << std::endl;
   std::map<std::string, Constraint*>::const_iterator citr = conss.begin();
   std::map<std::string, Constraint*>::const_iterator cend = conss.end();
   while( citr != cend )
   {
      citr->second->print(out);
      out << std::endl;
      ++citr;
   }
   
   out << "Vars:" << std::endl;
   vitr = vars.begin();
   vend = vars.end();
   while( vitr != vend )
   {
      vitr->second->print(out);
      out << std::endl;
      ++vitr;
   }
}

void Model::printSol(std::ostream& out) const
{
   out << "Solution: " << std::endl;
   std::map<std::string, Var*>::const_iterator vitr = vars.begin();
   std::map<std::string, Var*>::const_iterator vend = vars.end();
   while( vitr != vend )
   {
      out << vitr->second->name << " = " << vitr->second->value.toString() << std::endl;
      ++vitr;
   }
}

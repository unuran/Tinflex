
#include <R.h>
#include <Rdefines.h>
#include <Tinflex_lib.h>
#include "rdist.h"

/*---------------------------------------------------------------------------*/
/* define macros for GCC attributes                                          */

#ifdef __GNUC__
#  define ATTRIBUTE__UNUSED        __attribute__ ((unused))
#else
#  define ATTRIBUTE__UNUSED
#endif

  
/*---------------------------------------------------------------------------*/
/* Distribution 1                                                            */
/*---------------------------------------------------------------------------*/

/* extrema: -1.581, 0.0, 1.581 */

/* lf <- function(x) { -x^4 + 5*x^2 - 4 }  ## = (1 - x^2) * (x^2 - 4) */
/* dlf <- function(x) { 10*x - 4*x^3 } */
/* d2lf <- function(x) { 10 - 12*x^2 } */

double distr_1_lf (double x, const void *params  ATTRIBUTE__UNUSED) {
  double xsq = x*x;
  return (- xsq * xsq + 5. * xsq - 4.); /* = (1 - x^2) * (x^2 - 4) */
}

double distr_1_dlf (double x, const void *params  ATTRIBUTE__UNUSED) {
  return (10.*x - 4.*x*x*x );
}

double distr_1_d2lf (double x, const void *params  ATTRIBUTE__UNUSED) {
  return (10. - 12.*x*x );
}

/*---------------------------------------------------------------------------*/
/* Distribution 2                                                            */
/*---------------------------------------------------------------------------*/

/* extrema: -1, 0, 1 */

/* lf <- function(x) { -2*x^4 + 4*x^2 }  */
/* dlf <- function(x) { -8*x^3 + 8*x } */
/* d2lf <- function(x) { -24*x^2+8 } */


double distr_2_lf (double x, const void *params  ATTRIBUTE__UNUSED) {
  double xsq = x*x;
  return ((-2. * xsq + 4.) * xsq); /* = -2*x^4 + 4*x^2 */
}

double distr_2_dlf (double x, const void *params  ATTRIBUTE__UNUSED) {
  return (8. * (- x*x+ 1.) * x);
}

double distr_2_d2lf (double x, const void *params  ATTRIBUTE__UNUSED) {
  return (-24. * x*x + 8. );
}

/*---------------------------------------------------------------------------*/
/* Distribution 3                                                            */
/*---------------------------------------------------------------------------*/

/* extrema: 0 */

/* lf <- function(x) { log(1-x^4) } */
/* dlf <- function(x) { -4*x^3/(1-x^4) } */
/* d2lf <- function(x) { -(4*x^6+12*x^2)/(x^8-2*x^4+1) }  */

double distr_3_lf (double x, const void *params  ATTRIBUTE__UNUSED) {
  double xsq = x*x;
  return (log(1.-xsq*xsq)); /* = log(1-x^4) */
}

double distr_3_dlf (double x, const void *params  ATTRIBUTE__UNUSED) {
  double xsq = x*x;
  return (-4.*xsq*x/(1-xsq*xsq));
}

double distr_3_d2lf (double x, const void *params  ATTRIBUTE__UNUSED) {
  double xsq = x*x;
  double xc = x*xsq;
  return (-(4. * xc*xc + 12.*xsq)/(xc*xc*xsq - 2. * xsq*xsq + 1.));
}

/*---------------------------------------------------------------------------*/
/* Distribution 4                                                            */
/*---------------------------------------------------------------------------*/

/* extrema: 0 */

/* lf <- function(x) { -log(abs(x))/2 }  */
/* dlf <- function(x) { -1/(2*x) } */
/* d2lf <- function(x) { 1/(2*x^2) } */

double distr_4_lf (double x, const void *params  ATTRIBUTE__UNUSED) {
  return (-log(fabs(x))/2.);
}

double distr_4_dlf (double x, const void *params  ATTRIBUTE__UNUSED) {
  return (-1./(2.*x));
}

double distr_4_d2lf (double x, const void *params  ATTRIBUTE__UNUSED) {
  return (1./(2.*x*x));
}

/*---------------------------------------------------------------------------*/
/* Distribution 5: same as Distribution 2                                    */
/*---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------*/
/* Distribution 6                                                            */
/*---------------------------------------------------------------------------*/

/* lf <- function(x) { -x^4+6*x^2 } */
/* dlf <- function(x) { 12*x-4*x^3 } */
/* d2lf <- function(x) { 12-12*x^2 } */

double distr_6_lf (double x, const void *params  ATTRIBUTE__UNUSED) {
  double xsq = x*x;
  return (-xsq*xsq + 6.*xsq);
}

double distr_6_dlf (double x, const void *params  ATTRIBUTE__UNUSED) {
  return (x * (12. - 4. * x*x));
}

double distr_6_d2lf (double x, const void *params  ATTRIBUTE__UNUSED) {
  return (12. - 12. * x*x);
}


/*---------------------------------------------------------------------------*/
/* Create TinflexC object                                                    */
/* Wrapper for Tinflex_lib_setup()                                           */
/*---------------------------------------------------------------------------*/


typedef TINFLEX_GEN * TINFLEX_SETUP_FUNC (TINFLEX_FUNCT *lpdf, TINFLEX_FUNCT *dlpdf, TINFLEX_FUNCT *d2lpdf,
					  const void *params,
					  int n_ib, const double *ib,
					  int n_c, const double *c,
					  double rho, int max_intervals);

/*...........................................................................*/

static TINFLEX_GEN * rdist_run_setup (TINFLEX_FUNCT *lpdf, TINFLEX_FUNCT *dlpdf, TINFLEX_FUNCT *d2lpdf,
				      const void *params,
				      int n_ib, const double *ib,
				      int n_c, const double *c,
				      double rho, int max_intervals) {
  
  static TINFLEX_SETUP_FUNC *func = NULL;

  if (func == NULL)
    func = (TINFLEX_SETUP_FUNC*) R_GetCCallable("Tinflex", "Tinflex_lib_setup");

  return func (lpdf, dlpdf, d2lpdf, params, n_ib, ib, n_c, c, rho, max_intervals);
}

/*---------------------------------------------------------------------------*/
/* Select one of the test distributions and create TinflexC object           */
/*---------------------------------------------------------------------------*/

SEXP rdist_tag(void) {
  static SEXP tag = NULL; 
  if (!tag) tag = install("R_TINFLEX_C_TAG");
  return tag;
} /* end rdist_tag() */

/*...........................................................................*/

void rdist_free (SEXP sexp_gen)
{
  TINFLEX_GEN *gen;

  static void * (*free_func)(TINFLEX_GEN *) = NULL;
  if (free_func == NULL)
    free_func = R_GetCCallable("Tinflex", "Tinflex_lib_free");
  
  gen = R_ExternalPtrAddr(sexp_gen);
  free_func (gen);
  R_ClearExternalPtr(sexp_gen);
} /* end of rdist_free() */

/*...........................................................................*/

SEXP rdist_setup (SEXP sexp_obj,
		  SEXP sexp_type, SEXP sexp_ib, SEXP sexp_c,
		  SEXP sexp_rho, SEXP sexp_max_intervals)
{
  int type;
  const double *ib;
  int n_ib;
  const double *c;
  int n_c;
  double rho;
  int max_intervals;

  TINFLEX_FUNCT *lpdf=NULL;
  TINFLEX_FUNCT *dlpdf=NULL;
  TINFLEX_FUNCT *d2lpdf=NULL;
    
  TINFLEX_GEN *gen;
  SEXP sexp_gen = R_NilValue;

  /* extract arguments */
  type = INTEGER_VALUE(sexp_type);
  ib = REAL(sexp_ib);
  n_ib = length(sexp_ib);
  c = REAL(sexp_c);
  n_c = length(sexp_c);
  rho = NUMERIC_VALUE(sexp_rho);
  max_intervals = INTEGER_VALUE(sexp_max_intervals);

  /* select distribution type */
  switch(type) {
  case 1L:
    lpdf = distr_1_lf;
    dlpdf = distr_1_dlf;
    d2lpdf = distr_1_d2lf;
    break;
  case 2L:
  case 5L:  /* same as Distribution 2 */
    lpdf = distr_2_lf;
    dlpdf = distr_2_dlf;
    d2lpdf = distr_2_d2lf;
    break;
  case 3L:
    lpdf = distr_3_lf;
    dlpdf = distr_3_dlf;
    d2lpdf = distr_3_d2lf;
    break;
  case 4L:
    lpdf = distr_4_lf;
    dlpdf = distr_4_dlf;
    d2lpdf = distr_4_d2lf;
    break;
  case 6L:
    lpdf = distr_6_lf;
    dlpdf = distr_6_dlf;
    d2lpdf = distr_6_d2lf;
    break;
  default:
    error("Internal error!");
  }

  /* run setup */
  gen = rdist_run_setup (lpdf, dlpdf, d2lpdf, /*params=*/NULL,
		     n_ib, ib, n_c, c, rho, max_intervals);

  /* make R external pointer and store pointer to structure */
  PROTECT(sexp_gen = R_MakeExternalPtr(gen, rdist_tag(), sexp_obj));
  
  /* register destructor as C finalizer */
  R_RegisterCFinalizer(sexp_gen, rdist_free);

  /* return pointer to R */
  UNPROTECT(1);
    
  return (sexp_gen);

} /* end of distr_test_setup() */

/*---------------------------------------------------------------------------*/

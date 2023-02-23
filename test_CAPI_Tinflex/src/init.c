 
/*-------------------------------------------------------------------------*/

#include <R.h>
#include <Rinternals.h>
#include <stdlib.h> // for NULL
#include <R_ext/Rdynload.h>

#include "rdist.h"

/*-------------------------------------------------------------------------*/

static const R_CallMethodDef CallEntries[] = {
    {"rdist_setup", (DL_FUNC) &rdist_setup, 6},
    {NULL, NULL, 0}
};

/*-------------------------------------------------------------------------*/

void R_init_test_CAPI_Tinflex(DllInfo *dll)
{
  /* Register native routines */
  R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
  R_useDynamicSymbols(dll, FALSE);
  R_forceSymbols(dll, TRUE);
}

/*-------------------------------------------------------------------------*/

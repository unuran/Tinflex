/*****************************************************************************/
/*                                                                           */
/*   Tinflex                                                                 */
/*                                                                           */
/*   R <--> C programming interface (used in .Call)                          */
/*   (public part)                                                           */
/*                                                                           */
/*****************************************************************************/

SEXP make_guide_table (SEXP sexp_ivs, SEXP sexp_Acum, SEXP sexp_gt);
/*---------------------------------------------------------------------------*/
/* Create guide table for draw interval at random.                           */
/*---------------------------------------------------------------------------*/

SEXP Tinflex_sample (SEXP sexp_gen, SEXP sexp_n);
/*---------------------------------------------------------------------------*/
/* Draw sample from Tinflex generator object.                                */
/*---------------------------------------------------------------------------*/


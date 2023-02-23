# Tinflex

R package for generating from quite arbitrary univariate continuous
distributions.

The package also exports its C routines for linking into into other R
packages.

`Tinflex` is a universal non-uniform random number generator
based on the acceptence-rejection method for all distributions that
have a piecewise twice differentiable density function.
Required input includes the log-density function of
the target distribution and its first and (optionally) second
derivatives.

## Build and check

See `Makefile` for building and checking the package.

## References

* C. Botts, W. Hörmann, and J. Leydold (2013),
  Transformed Density Rejection with Inflection Points,
  Statistics and Computing 23(2), 251--260,
  DOI: 10.1007/s11222-011-9306-4. 
	
  See also Research Report Series / Department of Statistics and Mathematics
  Nr. 110, Department of Statistics and Mathematics,
  WU Vienna University of Economics and Business,
  URL: <https://epub.wu.ac.at/id/eprint/3158>.
  
* W. Hörmann, and J. Leydold (2022),
  A Generalized Transformed Density Rejection Algorithm,
  in: Advances in Modeling and Simulation, Ch. 14, 283-300,
  DOI: 10.1007/978-3-031-10193-9_14.
  
  See also 
  Research Report Series / Department of Statistics and Mathematics
  Nr. 135, Department of Statistics and Mathematics, 
  WU Vienna University of Economics and Business,
  <https://research.wu.ac.at/de/publications/a-generalized-transformed-density-rejection-algorithm>.



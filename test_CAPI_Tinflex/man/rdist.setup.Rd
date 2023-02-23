\name{rdist.setup}
\alias{rdist.setup}

\title{Creates a TinflexC object for a couple of test distributions}

\description{
  Creates a TinflexC object for a couple of test distributions.
  See source \file{src/rdist.c} for implemented test distributions and
  possible values for \code{type}.
}

\usage{
rdist.setup(type, ib, cT = 0, rho = 1.1, max.intervals = 1001)
}

\arguments{
  \item{type}{
    Type of test distribution, see source \file{src/rdist.c} for
    possible values.
}
  \item{ib}{
    See \code{\link[Tinflex]{Tinflex.setup}}.
}
  \item{cT}{
    See \code{\link[Tinflex]{Tinflex.setup}}.
}
  \item{rho}{
    See \code{\link[Tinflex]{Tinflex.setup}}.
}
  \item{max.intervals}{
    See \code{\link[Tinflex]{Tinflex.setup}}.
}
}

\details{
  This routine is just for testing the C API of \pkg{Tinflex}.
}
\value{
  Returns an object of class \code{TinflexC}.
}
\author{
  Josef Leydold \email{josef.leydold@wu.ac.at}
}

\seealso{
  \code{\link[Tinflex]{Tinflex.setup}} and package \pkg{Tinflex}.
}

%% \examples{}

#############################################################################
##                                                                         ## 
## Tests for Tinflex and Tinflex C API.                                    ## 
##                                                                         ## 
#############################################################################

## Load libraries -----------------------------------------------------------

require(Tinflex)
require(test.CAPI.Tinflex)

## Constants ----------------------------------------------------------------

## Seed for running tests.
SEED <- 123456
set.seed(SEED)

## Sample size for goodness-of-fit (GoF) tests.
## (if n.GoF, then is >= 1e7 then it is rounded to a multiple of 1e7.)
n.GoF <- 1e5

## Sample size for creating histogram.
## (if <= 0, then no histgram is plotted.)
n.hist <- 1e4

## Sample size for comparing R and C version of sampling routine.
## (if <= 0, then test is skipped.)
n.comp <- 100

## Requested maximal ratio rho = A.hat / A.squeeze.
rho <- 1.1

## Lower bounded for accepted p-values.
pval.threshold <- 1e-4

## Print numbers very accurately.
options(digits = 15)

## Load auxiliary libraries -------------------------------------------------

if (  
    ## Routines for testing non-uniform random variate generators.
    require(rvgtest) &&
    ## Function for approximate quantile function.
    require(Runuran) ) {

  ## We have all required libraries.
  have.UNURAN <- TRUE

} else {
  warning("Packages 'Runuran' and 'rvgtest' needed for testing!")
  have.UNURAN <- FALSE
}
 
## Global variables ---------------------------------------------------------

## Start timer.
time.start <- proc.time()

## Vector for storing p-values of tests.
pvals <- numeric(0)

## Number of compare tests that fail.
comp.sample.fail <- 0
comp.object.fail <- 0

## Auxiliary functions ------------------------------------------------------

## Plot histogram and run GoF tests (only if 'Runuran' is installed). .......

run.test <- function(id, type, lf, dlf, d2lf, ib, cT, rho, plot=FALSE) {

    ## lower and upper bound for domain
    ib <- sort(ib)
    lb <- ib[1]
    ub <- ib[length(ib)]
    
    ## create Tinflex objects
    genR <- Tinflex.setup(lf, dlf, d2lf, ib=ib, cT=cT, rho=rho)
    genC <- Tinflex.setup.C(lf, dlf, d2lf, ib=ib, cT=cT, rho=rho)
    genX <- Tinflex:::Tinflex.C2R(genC)
    genL <- rdist.setup(type=type, ib=ib, cT=cT, rho=rho)

    ## compare objects
    if (!isTRUE(all.equal(genR, genX))) {
        comp.object.fail <<- comp.object.fail + 1
        cat(paste("Warning - FAIL - object!  [id=",id,"]\n",
                  "genR and converted genC differ!\n"))
        print(all.equal(genR,genX))
        if (! isTRUE(all.equal(genR$gt, genX$gt))) {
            cat ("guide table: sum of absolute differences =",sum(abs(genR$gt-genX$gt)),"\n")
        }
    }

    genLX <- Tinflex:::Tinflex.C2R(genL)
    genLX$lpdf <- genR$lpdf           ## genLX$lpdf is NULL
    genLX$env <- genR$env 
    if (!isTRUE(all.equal(genR, genLX))) {
        comp.object.fail <<- comp.object.fail + 1
        cat(paste("Warning - FAIL - object!  [id=",id,"]\n",
                  "genR and converted genLX differ!\n"))
        print(all.equal(genR,genLX))
        if (! isTRUE(all.equal(genR$gt, genLX$gt))) {
            cat ("guide table: sum of absolute differences =",sum(abs(genR$gt-genLX$gt)),"\n")
        }
    }
    rm(genLX)
    
    ## Print generator in debugging mod.e
    print(genR, debug=TRUE)

    ## Plot density, hat and squeeze.
    if (plot) {
        plot(genR, from=max(lb,-3), to=min(ub,3), is.trans=FALSE, main=paste("c =",cT))
        plot(genR, from=max(lb,-3), to=min(ub,3), is.trans=TRUE,  main=paste("c =",cT))
    }
  
    if (n.comp > 0) {

        ## Compare R and C version of sampling routine.
        set.seed(SEED)
        x.R <- Tinflex:::Tinflex.sample.R(genR,n=n.comp)
        set.seed(SEED)
        x.RC <- Tinflex.sample(genR,n=n.comp)
        if (!isTRUE(all.equal(x.R,x.RC))) {
            comp.sample.fail <<- comp.sample.fail + 1
            d <- x.R - x.RC
            cat(paste("Warning - FAIL - sample!  [id=",id,"]\n",
                      "R and C versions differ!\n",
                      "\tsample size =",n.comp,"\n",
                      "\t  different =",length(d[d!=0]),"\n\n"))
            cat("output of R version:\n")
            print(x.R[d!=0])
            cat("difference to C version:\n")
            print(d[d!=0])
            ## Remark: x.R and x.RC may differ due to different round-off errors
            ## in the C and R version, resp.
            ## Thus we only print a message.
        }
    
        ## Compare Tinflex and TinflexC versions.
        set.seed(SEED)
        x.C <- Tinflex.sample.C(genC,n=n.comp)
        if (!isTRUE(all.equal(x.R,x.C))) {
            comp.sample.fail <<- comp.sample.fail + 1
            d <- x.R - x.C
            cat(paste("Warning - FAIL - sample!  [id=",id,"]\n",
                "R and pure C versions differ!\n",
                "\tsample size =",n.comp,"\n",
                "\t  different =",length(d[d!=0]),"\n\n"))
            cat("output of R version:\n")
            print(x.R[d!=0])
            cat("difference to pure C version:\n")
            print(d[d!=0])
        }

        ## Compare Tinflex and Tinflex_lib versions.
        set.seed(SEED)
        x.L <- Tinflex.sample.C(genL,n=n.comp)
        if (!isTRUE(all.equal(x.R,x.L))) {
            comp.sample.fail <<- comp.sample.fail + 1
            d <- x.R - x.L
            cat(paste("Warning - FAIL - sample!  [id=",id,"]\n",
                "R and pure C versions differ!\n",
                "\tsample size =",n.comp,"\n",
                "\t  different =",length(d[d!=0]),"\n\n"))
            cat("output of R version:\n")
            print(x.R[d!=0])
            cat("difference to lib version:\n")
            print(d[d!=0])
        }
    }
  
    ## Create a histogram and run GoF test (when Runuran is available).
    if (isTRUE(have.UNURAN)) {
        ## Set seed for tests.
        set.seed(SEED)
        
        ## Create frequency table (using packages 'Runuran' and 'rvgtest')
        if (n.GoF < 1e7) {
            m <- 1
            n <- n.GoF
        } else {
            m <- round(n.GoF / 1e7)
            n <- 1e7
        }      
        ug <- pinv.new(pdf=lf, lb=lb, ub=ub, islog=TRUE, center=0, uresolution=1.e-14)
        tb <- rvgt.ftable(n=n, rep=m,
                          rdist=function(n){Tinflex.sample(genR,n=n)},
                          qdist=function(u){uq(ug,u)})
        
        ## Plot histgram of random sample.
        if (plot && n.hist > 0)
            hist(Tinflex.sample(genR,n=n.hist), breaks=101, main=paste("c =",cT))
        
        ## Plot frequency table,
        if (plot) {
            plot(tb, main=paste("c =",cT))
        }
        
        ## Run GoF test.
        gof <- rvgt.chisq(tb)
        print(gof)
        if(! isTRUE(gof$pval[m] >= pval.threshold))
            warning("[id=",id,"]  p-value too small. GoF test failed!")
        
        ## Store p-value.
        pvals <<- append(pvals, gof$pval[m])
    }
    else {
        ## Package 'Runuran' or 'rvgtest' is not installed.
        ## Thus we only plot a histgram.
        if (plot && n.hist > 0)
            hist(Tinflex.sample(genR,n=n.hist), breaks=101, main=paste("c =",cT))
    }
}

## Test whether there is an error. ..........................................
is.error <- function (expr) { is(try(expr), "try-error") }

#############################################################################
## Distribution 1
#############################################################################

lf <- function(x) { -x^4 + 5*x^2 - 4 }  ## = (1 - x^2) * (x^2 - 4)
dlf <- function(x) { 10*x - 4*x^3 }
d2lf <- function(x) { 10 - 12*x^2 }

## extrema: -1.581, 0.0, 1.581

## c = 1.5 ------------------------------------------------------------------
## inflection points: -1.7620, -1.4012, 1.4012, 1.7620
cT <- 1.5
run.test(id="1|1.5", type=1, lf, dlf, d2lf, ib=c(-3,-1.5,0,1.5,3), cT=cT, rho=rho)

## c = 1 --------------------------------------------------------------------
## inflection points: -1.8018, -1.3627, 1.3627, 1.8018
cT <- 1
run.test(id="1|1",  type=1, lf, dlf, d2lf, ib=c(-3,-1.5,0,1.5,3), cT=cT, rho=rho)

## c = 0.5 ------------------------------------------------------------------
## inflection points: -1.8901, -1.2809, 1.2809, 1.8901
cT <- 0.5
run.test(id="1|0.5", type=1, lf, dlf, d2lf, ib=c(-3,-1.5,0,1.5,3), cT=cT, rho=rho)

## c = 0.1 ------------------------------------------------------------------
## inflection points: -2.2361, -1.0574, 1.0574, -2.2361
cT <- 0.1
run.test(id="1|0.1", type=1, lf, dlf, d2lf, ib=c(-3,-1.5,0,1.5,3), cT=cT, rho=rho)

## c = 0 --------------------------------------------------------------------
## inflection points: -0.9129, 0.9129
cT <- 0
run.test(id="1|0a", type=1, lf, dlf, d2lf, ib=c(-Inf,-2.1,-1.05,0.1,1.2,2,Inf), cT=cT, rho=rho)
run.test(id="1|0b", type=1, lf, dlf, d2lf, ib=c(-Inf,-1,0,1,Inf), cT=cT, rho=rho)
run.test(id="1|0c", type=1, lf, dlf, d2lf, ib=c(-2,0,1.5), cT=cT, rho=rho)

## c = -0.2 -----------------------------------------------------------------
## inflection points: -0.4264, 0.4264
cT <- -0.2
run.test(id="1|-0.2a", type=1, lf, dlf, d2lf, ib=c(-Inf,-2.1,-1.05,0.1,1.2,2,Inf), cT=cT, rho=rho)
run.test(id="1|-0.2b", type=1, lf, dlf, d2lf, ib=c(-Inf,-1,0,1,Inf), cT=cT, rho=rho)
run.test(id="1|-0.2c", type=1, lf, dlf, d2lf, ib=c(-2,0,1.5), cT=cT, rho=rho)

## c = -0.5 -----------------------------------------------------------------
## inflection points: -0.4264, 0.4264
cT <- -0.5
run.test(id="1|-0.5a", type=1, lf, dlf, d2lf, ib=c(-Inf,-2.1,-1.05,0.1,1.2,2,Inf), cT=cT, rho=rho)
run.test(id="1|-0.5b", type=1, lf, dlf, d2lf, ib=c(-Inf,-1,0,1,Inf), cT=cT, rho=rho)
run.test(id="1|-0.5c", type=1, lf, dlf, d2lf, ib=c(-2,0,1.5), cT=cT, rho=rho)

## c = -0.9 -----------------------------------------------------------------
## inflection points: -0.4264, 0.4264
cT <- -0.9
run.test(id="1|-0.9a", type=1, lf, dlf, d2lf, ib=c(-Inf,-2.1,-1.05,0.1,1.2,2,Inf), cT=cT, rho=rho)
run.test(id="1|-0.9b", type=1, lf, dlf, d2lf, ib=c(-Inf,-1,0,1,Inf), cT=cT, rho=rho)
run.test(id="1|-0.9c", type=1, lf, dlf, d2lf, ib=c(-2,0,1.5), cT=cT, rho=rho)

## c = -1 -------------------------------------------------------------------
## inflection points: -0.3094, -0.3094
cT <- -1
run.test(id="1|-1", type=1, lf, dlf, d2lf, ib=c(-3,-1.5,0,1.5,3), cT=cT, rho=rho)

## c = -1.5 -----------------------------------------------------------------
## inflection points: -0.2546, 0.2546
cT <- -1.5
run.test(id="1|-1.5", type=1, lf, dlf, d2lf, ib=c(-3,-1.5,0,1.5,3), cT=cT, rho=rho)

## c = -2 -------------------------------------------------------------------
## inflection points: -0.2213, 0.2213
cT <- -2
run.test(id="1|-2", type=1, lf, dlf, d2lf, ib=c(-3,-1.5,0,1.5,3), cT=cT, rho=rho)


#############################################################################
## Distribution 2
## Test construction points at and near extrema.
#############################################################################

##lf <- function(x) { -2*x^4 + 4*x^2 } 
##dlf <- function(x) { -8*x^3 + 8*x }
##d2lf <- function(x) { -24*x^2+8 }

lf <- function(x) { (-2*x^2 + 4)*x^2 } 
dlf <- function(x) { 8 * (-x^2 + 1) *x }
d2lf <- function(x) { -24*x^2+8 }

## extrema: -1, 0, 1

## special boundary points:
##   points where the slope of the tangent is identical 0.
ivb.1 <- c(-Inf, -2, -1, 0, 1, 2, Inf) 
##   points where the slope of the tangent is almost 0
##   but not identical 0 (and thus might cause numerical errors).
ivb.2 <- c(-Inf, -2, -1+2^(-52), 1e-20, 1-2^(-53), 2, Inf) 

ivb.3 <- c(-3, -1, 0, 1, 3) 
ivb.4 <- c(-3, -1+2^(-52), 1e-20, 1-2^(-53), 3) 

## c = 2 --------------------------------------------------------------------
## inflection points: -1.1734, -0.8300, 0.8300, 1.1734
cT <- 2

## slope = 0
run.test(id="2|2a", type=2, lf, dlf, d2lf, ib=ivb.3, cT=cT, rho=rho)

## slope ~ 0
run.test(id="2|2b", type=2, lf, dlf, d2lf, ib=ivb.4, cT=cT, rho=rho)

## c = 1.5 ------------------------------------------------------------------
## inflection points: -1.1993, -0.8067, 0.8067, 1.1993
cT <- 1.5

## slope = 0
run.test(id="2|1.5a", type=2, lf, dlf, d2lf, ib=ivb.3, cT=cT, rho=rho)

## slope ~ 0
run.test(id="2|1.5b", type=2, lf, dlf, d2lf, ib=ivb.4, cT=cT, rho=rho)

## c = 1 --------------------------------------------------------------------
## inflection points: -1.2418, -0.7709, -0.7709, 1.2418
cT <- 1

## slope = 0
run.test(id="2|1a", type=2, lf, dlf, d2lf, ib=ivb.3, cT=cT, rho=rho)

## slope ~ 0
run.test(id="2|1b", type=2, lf, dlf, d2lf, ib=ivb.4, cT=cT, rho=rho)

## c = 0.5 ------------------------------------------------------------------
## inflection points: -1.3345, -0.7071, 0.7071, 1.3345
cT <- 0.5

## slope = 0
run.test(id="2|0.5a", type=2, lf, dlf, d2lf, ib=ivb.3, cT=cT, rho=rho)

## slope ~ 0
run.test(id="2|0.5b", type=2, lf, dlf, d2lf, ib=ivb.4, cT=cT, rho=rho)

## c = 0 --------------------------------------------------------------------
## inflection points: -0.5774, 0.5774, 
cT <- 0

## slope = 0
run.test(id="2|0a", type=2, lf, dlf, d2lf, ib=ivb.1, cT=cT, rho=rho)

## slope ~ 0
run.test(id="2|0b", type=2, lf, dlf, d2lf, ib=ivb.2, cT=cT, rho=rho)

## c = -0.2 -----------------------------------------------------------------
## inflection points: -0.5076, 0.5076
cT <- -0.2

## slope = 0
run.test(id="2|-0.2a", type=2, lf, dlf, d2lf, ib=ivb.1, cT=cT, rho=rho)

## slope ~ 0
run.test(id="2|-0.2b", type=2, lf, dlf, d2lf, ib=ivb.2, cT=cT, rho=rho)

## c = -0.5 -----------------------------------------------------------------
## inflection points: -0.4180, 0.4180
cT <- -0.5

## slope = 0
run.test(id="2|-0.5a", type=2, lf, dlf, d2lf, ib=ivb.1, cT=cT, rho=rho)

## slope ~ 0
run.test(id="2|-0.5b", type=2, lf, dlf, d2lf, ib=ivb.2, cT=cT, rho=rho)

## c = -0.9 -----------------------------------------------------------------
## inflection points: -0.3404, 0.3404
cT <- -0.9

## slope = 0
run.test(id="2|-0.9a", type=2, lf, dlf, d2lf, ib=ivb.1, cT=cT, rho=rho)

## slope ~ 0
run.test(id="2|-0.9b", type=2, lf, dlf, d2lf, ib=ivb.2, cT=cT, rho=rho)

## c = -1 -------------------------------------------------------------------
## inflection points: -0.3264, 0.3264
cT <- -1

## slope = 0
run.test(id="2|-1a", type=2, lf, dlf, d2lf, ib=ivb.3, cT=cT, rho=rho)

## slope ~ 0
run.test(id="2|-1b", type=2, lf, dlf, d2lf, ib=ivb.4, cT=cT, rho=rho)

## c = -1.1 ------------------------------------------------------------------
## inflection points: -0.3139, 0.3139
cT <- -1.1

## slope = 0
run.test(id="2|-1.1a", type=2, lf, dlf, d2lf, ib=ivb.3, cT=cT, rho=rho)

## slope ~ 0
run.test(id="2|-1.1b", type=2, lf, dlf, d2lf, ib=ivb.4, cT=cT, rho=rho)

## c = -2 --------------------------------------------------------------------
## inflection points: -0.2412, 0.2412
cT <- -2

## slope = 0
run.test(id="2|-2a", type=2, lf, dlf, d2lf, ib=ivb.3, cT=cT, rho=rho)

## slope ~ 0
run.test(id="2|-2b", type=2, lf, dlf, d2lf, ib=ivb.4, cT=cT, rho=rho)

rm(ivb.1, ivb.2, ivb.3, ivb.4)


#############################################################################
## Distribution 3
## Test density that vanishes at boundaries of bounded domain.
#############################################################################

lf <- function(x) { log(1-x^4) }
dlf <- function(x) { -4*x^3/(1-x^4) }
## extrema: 0
d2lf <- function(x) { -(4*x^6+12*x^2)/(x^8-2*x^4+1) } 

## domain: lb=-1, ub=1

## c = 2   ------------------------------------------------------------------
## inflection points: -0.8091, [ 0 ], 0.8091
cT <- 2
run.test(id="3|2", type=3, lf, dlf, d2lf, ib=c(-1,-0.9,-0.5,0.5,0.9,1), cT=cT, rho=rho)

## c = 1.5 ------------------------------------------------------------------
## inflection points: -0.8801, [ 0 ], 0.8801
cT <- 1.45
## Remark: for cT=1.5 objects differ due to round-off errors when
## the hat intersects the x-axis.
run.test(id="3|1.5", type=3, lf, dlf, d2lf, ib=c(-1,-0.9,-0.5,0.5,0.9,1), cT=cT, rho=rho)

## c = 1 --------------------------------------------------------------------
## inflection points: [ 0 ]
cT <- 1
run.test(id="3|1", type=3, lf, dlf, d2lf, ib=c(-1,-0.5,0,0.5,1), cT=cT, rho=rho)

## c = 0.5 ------------------------------------------------------------------
cT <- 0.5
run.test(id="3|0.5", type=3, lf, dlf, d2lf, ib=c(-1,-0.5,0,0.5,1), cT=cT, rho=rho)

## c = 0.1 ------------------------------------------------------------------
cT <- 0.1
run.test(id="3|0.1", type=3, lf, dlf, d2lf, ib=c(-1,-0.5,0,0.5,1), cT=cT, rho=rho)

## c = 0 --------------------------------------------------------------------
cT <- 0
run.test(id="3|0", type=3, lf, dlf, d2lf, ib=c(-1,-0.5,0,0.5,1), cT=cT, rho=rho)

## c = -0.2 -----------------------------------------------------------------
cT <- -0.2
run.test(id="3|-0.2", type=3, lf, dlf, d2lf, ib=c(-1,-0.5,0,0.5,1), cT=cT, rho=rho)

## c = -0.5 -----------------------------------------------------------------
cT <- -0.5
run.test(id="3|-0.5", type=3, lf, dlf, d2lf, ib=c(-1,-0.5,0,0.5,1), cT=cT, rho=rho)

## c = -0.9 -----------------------------------------------------------------
cT <- -0.9
run.test(id="3|-0.9", type=3, lf, dlf, d2lf, ib=c(-1,-0.5,0,0.5,1), cT=cT, rho=rho)

## c = -1 -------------------------------------------------------------------
cT <- -1
run.test(id="3|-1", type=3, lf, dlf, d2lf, ib=c(-1,-0.5,0,0.5,1), cT=cT, rho=rho)

## c = -1.5 -----------------------------------------------------------------
cT <- -1.5
run.test(id="3|-1.5", type=3, lf, dlf, d2lf, ib=c(-1,-0.5,0,0.5,1), cT=cT, rho=rho)

## c = -2 -------------------------------------------------------------------
cT <- -2
run.test(id="3|-2", type=3, lf, dlf, d2lf, ib=c(-1,-0.5,0,0.5,1), cT=cT, rho=rho)


#############################################################################
## Distribution 4
## Test density with pole.
#############################################################################

lf <- function(x) { -log(abs(x))/2 }    ## 1/sqrt(x)
dlf <- function(x) { -1/(2*x) }
## extrema: 0
d2lf <- function(x) { 1/(2*x^2) }

## c = -1.5 -----------------------------------------------------------------
cT <- -1.5
run.test(id="4|-1.5", type=4, lf, dlf, d2lf, ib=c(-1,0,1), cT=cT, rho=rho)


#############################################################################
## Distribution 5
## Test different values for 'c'
#############################################################################

##lf <- function(x) { -2*x^4 + 4*x^2 } 
##dlf <- function(x) { -8*x^3 + 8*x }
##d2lf <- function(x) { -24*x^2+8 }

lf <- function(x) { (-2*x^2 + 4)*x^2 } 
dlf <- function(x) { 8 * (-x^2 + 1) *x }
d2lf <- function(x) { -24*x^2+8 }

## extrema: -1, 0, 1
## Remark: same as Distribution 2

cT <- c(-0.5, 2, -2, 0.5, -1, 0)
ib <- c(-Inf,-2, -1,   0,  1, 2, Inf)
run.test(id="5|multa", type=2, lf, dlf, d2lf, ib=ib, cT=cT, rho=rho)

cT <- c(-0.5, 2, -2, 0.5, -1, 0)
ib <- c(  -3,-2, -1,   0,  1, 2, 3)
run.test(id="5|multb", type=2, lf, dlf, d2lf, ib=ib, cT=cT, rho=rho)

rm(cT, ib)


#############################################################################
## Distribution 6
## Test density with infection point at interval boundary
#############################################################################

## c = 0 --------------------------------------------------------------------
cT <- 0

lf <- function(x) { -x^4+6*x^2 }
##dlf <- function(x) { 12*x-4*x^3 }
dlf <- function(x) { x * (12-4*x^2) }
d2lf <- function(x) { 12-12*x^2 }

## inflection points: -1, 1

run.test(id="6|", type=6, lf, dlf, d2lf, ib=c(-Inf,-2,-1,0,1,2,Inf), cT=cT, rho=rho)


#############################################################################
## Summary of tests.
#############################################################################

## Number of tests.
length(pvals)

## p-values for goodness-of-fit tests.
summary(pvals)
  
## Level-2 test for p-values (must be uniformly distributed).
if (length(pvals)>0)
  ks.test(x=pvals, y="punif", alternative = "greater")

## Print number of tests where different implemenations return different results.
cat("Random samples: Number of fails =",comp.sample.fail,"\n\n")

cat("Tinflex objects: Number of fails =",comp.object.fail,"\n\n")

## Stop timer.
run.time <- (proc.time() - time.start)[3]  ## "elapsed" time
run.time

## Failed tests?
if (length(pvals[pvals < pval.threshold])) {
  stop (paste(length(pvals[pvals < pval.threshold]),"out of",length(pvals),
              "goodness-of-fit tests failed!"))
} else {
  cat ("All goodness-of-fit tests passed!\n")
}
  

#############################################################################

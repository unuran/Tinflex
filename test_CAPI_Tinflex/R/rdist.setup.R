
rdist.setup <- function(type, ib, cT=0, rho=1.1, max.intervals=1001)
{
    ## Store some of the arguments for print.Tinflex().
    iniv <- paste(paste("    initial intervals ="),
                  paste(ib,collapse=" | "),
                  paste("\n                   cT ="),
                  paste(cT,collapse=" | "),
                  paste("\n                  rho =",rho,"\n"))

    ## Create S3 class that contains generator.
    generator <- list(
        ivs=NULL,          ## data for hat and squeeze
        lpdf=NULL,         ## log-density
        A.ht.tot=NULL,     ## total area below hat
        A.sq.tot=NULL,     ## total area below hat
        env=NULL,          ## environment for evaluating log-density
        iniv=iniv,         ## initial intervals (for print.Tinflex)
        Acum=NULL,         ## cumulated areas
        gt=NULL,           ## guide table
        Cgen=NULL          ## pointer to external C structure
    )
    class(generator) <- "TinflexC"

    ## Create TinflexC object
    generator$Cgen <- .Call(C_rdist_setup, generator,
                            type, ib, cT, rho, max.intervals)

    ## Return generator object. 
    generator
}


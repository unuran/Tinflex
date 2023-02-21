##
## Run the following command on this file:
##   cd Tinflex/devel
##   R CMD BATCH --vanilla make_Tinflex_source_h.R

## load R code
source("../R/setup.R")

## output file
of <- "../src/Tinflex_source.h"

## file header
cat("/*\n", file=of)
cat(" * -- Automatically created from 'setup.R'\n", file=of, append=TRUE)
cat(" *", date(), "\n", file=of, append=TRUE)
cat(" */\n\n", file=of, append=TRUE)

## names parameter for hat and squeeze
cat("/* Number of data for each interval */\n", file=of, append=TRUE)
cat("static const int L_IVS =",length(iv.struct),
    "; /* = length(iv.struct) */\n\n", file=of, append=TRUE)

cat("/* Parameters for each interval */\n", file=of, append=TRUE)
cat("enum {\n", file=of, append=TRUE)
for (i in 1:length(iv.struct)) {
  s <- iv.struct[i]
  s <- gsub("(\\w*)", "\\U\\1", s, perl=TRUE)
  s <- gsub("\\.", "_", s)
  cat(sprintf("\tIV_%s = %d,\n", s, i-1), file=of, append=TRUE)
}
cat("};\n\n", file=of, append=TRUE)

## Names of list elements for generator
cat("/* Names of list elements for generator */\n", file=of, append=TRUE)
cat("enum {\n", file=of, append=TRUE)
for (i in 1:length(gen.struct)) {
  s <- gen.struct[i]
  s <- gsub("(\\w*)", "\\U\\1", s, perl=TRUE)
  s <- gsub("\\.", "_", s)
  cat(sprintf("\tGEN_%s = %d,\n", s, i-1), file=of, append=TRUE)
}
cat("};\n\n", file=of, append=TRUE)

## end

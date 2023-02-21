
# --- Constants -------------------------------------------------------------

# name of project
project = Tinflex

# name of R program
R = R

# --- Default target --------------------------------------------------------

all: help

# --- Help ------------------------------------------------------------------

help:
	@echo ""
	@echo "build  ... build package 'Tinflex'"
	@echo "check  ... check package 'Tinflex'"
	@echo "clean  ... clear working space"
	@echo ""

# --- Phony targets ---------------------------------------------------------

.PHONY: all help clean maintainer-clean clean build check

# --- Tinflex ---------------------------------------------------------------

build:
	${R} CMD build ${project}

check:
	(unset TEXINPUTS; _R_CHECK_TIMINGS_=0 ${R} CMD check --as-cran ${project}_*)

clean-Tinflex:
	@rm -rvf ${project}.Rcheck
	@rm -fv ${project}_*.tar.gz
	@rm -fv ./Tinflex/make_Tinflex_RC_arrays_h.Rout
	@rm -fv ./Tinflex/src/*.o ./Tinflex/src/*.so 
	@rm -fv ./Tinflex/man/*.pdf

# --- Tinflex C API test ----------------------------------------------------

clean-TinflexCAPItest:
	@rm -rvf TinflexCAPItest.Rcheck
	@rm -fv TinflexCAPItest_*.tar.gz
	@rm -fv ./TinflexCAPItest/src/*.o ./TinflexCAPItest/src/*.so 
	@rm -fv ./TinflexCAPItest/man/*.pdf

build-TinflexCAPItest:
	${R} CMD build TinflexCAPItest

check-TinflexCAPItest:
	(unset TEXINPUTS; _R_CHECK_TIMINGS_=0 ${R} CMD check TinflexCAPItest_*)


# --- Clear working space ---------------------------------------------------

clean:
	@make clean-Tinflex
	@make clean-TinflexCAPItest
	@find -L . -type f -name "*~" -exec rm -v {} ';'

	@rm -fv ./Tinflex-log/tests-Tinflex-log.Rout
	@rm -fv ./Tinflex-log/Rplots.pdf

	@(cd examples && make clean)
	@(cd experiments && make clean)

maintainer-clean: clean

# --- End -------------------------------------------------------------------

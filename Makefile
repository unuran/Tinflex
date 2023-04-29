#############################################################################
#
#  Makefile for building and checking R package 'Tinflex'
#
#############################################################################

# --- Constants -------------------------------------------------------------

# name of project
project = Tinflex

# name of R program
R = R

# --- Help (default target) -------------------------------------------------

help:
	@echo ""
	@echo "  build    ... build package '${project}'"
	@echo "  check    ... check package '${project}' (run 'R CMD check')"
	@echo "  version  ... update version number and release date in documentation"
	@echo "  valgrind ... check package '${project}' using valgrind (very slow!)"
	@echo "  clean    ... clear working space"
	@echo ""
	@echo "  CAPI-check ... check C API of package '${project}'"
	@echo "  CAPI-valgrind ... check C API of package '${project}' using valgrind (very slow!)"
	@echo ""

# --- Phony targets ---------------------------------------------------------

.PHONY: help  build check clean valgrind version CAPI-build CAPI-check CAPI-valgrind

# --- Tinflex ---------------------------------------------------------------

build:
	${R} CMD build ${project}

check:
	(unset TEXINPUTS; ${R} CMD check --as-cran ${project}_*.tar.gz)

version:
	(cd ${project} && ../scripts/update-docu.pl -u)

valgrind:
	(unset TEXINPUTS; ${R} CMD check --use-valgrind ${project}_*.tar.gz)
	@echo -e "\n * Valgrind output ..."
	@for Rout in `find ${project}.Rcheck/ -name *.Rout`; \
		do echo -e "\n = $$Rout:\n"; \
		grep -e '^==[0-9]\{3,\}== ' $$Rout; \
	done

# --- Tinflex C API test ----------------------------------------------------

CAPI-build:
	@echo -e "\n * Checking C API of package '${project}'!\n"
	@echo "Ensure that package '${project}' is installed!" | sed 'h;s/./=/g;p;x;p;x'
	@echo -e "\n * Building package ...\n"
	${R} CMD build test_CAPI_${project}

CAPI-check: CAPI-build
	@echo -e "\n * Checking package ...\n"
	(unset TEXINPUTS; ${R} CMD check test.CAPI.${project}_*.tar.gz)

CAPI-valgrind: CAPI-build
	@echo -e "\n * Checking package ...\n"
	(unset TEXINPUTS; ${R} CMD check --use-valgrind test.CAPI.${project}_*.tar.gz)
	@echo -e "\n * Valgrind output ..."
	@for Rout in `find test.CAPI.${project}.Rcheck/ -name *.Rout`; \
		do echo -e "\n = $$Rout:\n"; \
		grep -e '^==[0-9]\{3,\}== ' $$Rout; \
	done

# --- Clear working space ---------------------------------------------------

clean:
# Remove compiled files
	@rm -fv ./${project}/src/*.o ./${project}/src/*.so ./${project}/src/symbols.rds
# Remove R package files
	@rm -rf ${project}.Rcheck
	@rm -fv ${project}_*.tar.gz
# Remove emacs backup files
	@find -L . -type f -name "*~" -exec rm -v {} ';'
# Remove CAPI files 
	@rm -rf test.CAPI.${project}.Rcheck
	@rm -fv test.CAPI.${project}_*.tar.gz

# --- End -------------------------------------------------------------------

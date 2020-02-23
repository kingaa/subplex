REXE = R --vanilla
RCMD = $(REXE) CMD
RCMD_ALT = R --no-save --no-restore CMD
RSCRIPT = Rscript --vanilla

PDFLATEX = pdflatex
BIBTEX = bibtex
MAKEIDX = makeindex

RM = rm -f
CP = cp
TOUCH = touch
INSTALL = install

PKG = $(shell perl -ne 'print $$1 if /Package:\s+((\w+[-\.]?)+)/;' DESCRIPTION)
VERSION = $(shell perl -ne 'print $$1 if /Version:\s+((\d+[-\.]?)+)/;' DESCRIPTION)
PKGVERS = $(PKG)_$(VERSION)
SOURCE=$(shell ls R/*R src/* man/*Rd tests/*R)

default:
	@echo $(PKGVERS)

.PHONY: clean win wind tests check

dist manual vignettes: export R_QPDF=qpdf
dist manual vignettes: export R_GSCMD=gs
dist manual vignettes: export GS_QUALITY=ebook
dist manual vignettes: export R_HOME=$(shell $(REXE) RHOME)
check xcheck xxcheck: export FULL_TESTS=yes
xcheck tests: export R_PROFILE_USER=$(CURDIR)/.Rprofile
htmldocs xxcheck vignettes data tests manual: export R_LIBS=$(CURDIR)/library
session: export R_DEFAULT_PACKAGES=datasets,utils,grDevices,graphics,stats,methods,subplex,tidyverse

includes: inst/include/pomp.h inst/include/pomp_defines.h

htmldocs: inst/doc/*.html

NEWS: inst/NEWS

inst/NEWS: inst/NEWS.Rd
	$(RCMD) Rdconv -t txt $^ -o $@

session: install
	exec $(REXE)

roxy: $(SOURCE)
##	$(REXE) -e "pkgload::load_all(compile=FALSE); devtools::document(roclets=c('rd','collate','namespace'))"
	$(REXE) -e "pkgbuild::compile_dll(); devtools::document(roclets=c('rd','collate','namespace'))"

dist: NEWS $(PKGVERS).tar.gz

$(PKGVERS).tar.gz: $(SOURCE)
	$(RCMD) build --force --no-manual --resave-data --compact-vignettes=both --md5 .

publish: dist manual
	$(RSCRIPT) -e 'drat::insertPackage("$(PKGVERS).tar.gz",repodir="../www",action="prune")'
	-$(RSCRIPT) -e 'drat::insertPackage("$(PKGVERS).tgz",repodir="../www",action="none")'
	-$(RSCRIPT) -e 'drat::insertPackage("$(PKGVERS).zip",repodir="../www",action="prune")'
	$(CP) $(PKG).pdf ../www/manuals

win: dist
	curl -T $(PKGVERS).tar.gz ftp://win-builder.r-project.org/R-release/

wind: dist
	curl -T $(PKGVERS).tar.gz ftp://win-builder.r-project.org/R-devel/

check: dist
	mkdir -p check
	$(RCMD) check --no-stop-on-test-error --library=check -o check $(PKGVERS).tar.gz

qcheck: dist
	mkdir -p check
	$(RCMD) check --library=check -o check --no-vignettes --no-tests $(PKGVERS).tar.gz

qqcheck: dist
	mkdir -p check
	$(RCMD) check --library=check -o check --no-codoc --no-examples --no-vignettes --no-manual --no-tests $(PKGVERS).tar.gz

xcheck: dist
	mkdir -p check library
	$(RCMD_ALT) check --no-stop-on-test-error --as-cran --library=library -o check $(PKGVERS).tar.gz

xxcheck: install xcheck
	mkdir -p check
	$(REXE) -d "valgrind --tool=memcheck --track-origins=yes --leak-check=full" < check/$(PKG).Rcheck/$(PKG)-Ex.R 2>&1 | tee $(PKG)-Ex.Rout

ycheck: dist
	mkdir -p check
	$(RCMD_ALT) check --run-dontrun --run-donttest --as-cran --library=library -o check $(PKGVERS).tar.gz

manual: install $(PKG).pdf

$(PKG).pdf: $(SOURCE)
	$(RCMD) Rd2pdf --no-preview --pdf --force -o $(PKG).pdf .
	$(RSCRIPT) -e "tools::compactPDF(\"$(PKG).pdf\")";

tests: install tests/*.R
	export R_LIBS
	$(MAKE) -C tests

install: library/$(PKG)

library/$(PKG): dist
	mkdir -p library
	$(RCMD) INSTALL --library=library $(PKGVERS).tar.gz

remove:
	-$(RCMD) REMOVE --library=library $(PKG)
	-rmdir library

inst/include/%.h: src/%.h
	$(CP) $^ $@

inst/doc/*.html: install 

%.tex: %.Rnw
	$(RSCRIPT) -e "library(knitr); knit(\"$*.Rnw\")"

%.R: %.Rnw
	$(RSCRIPT) -e "library(knitr); purl(\"$*.Rnw\")"

%.pdf: %.tex
	$(PDFLATEX) $*
	-$(BIBTEX) $*
	$(PDFLATEX) $*
	$(PDFLATEX) $*

%.bbl: %.tex
	-$(PDFLATEX) $*
	$(BIBTEX) $*

%.idx: %.tex
	-$(PDFLATEX) $*

%.ind: %.idx
	$(MAKEIDX) $*

%.html: %.Rmd
	PATH=/usr/lib/rstudio/bin/pandoc:$$PATH \
	Rscript --vanilla -e "rmarkdown::render(\"$*.Rmd\")"

%.html: %.md
	PATH=/usr/lib/rstudio/bin/pandoc:$$PATH \
	Rscript --vanilla -e "rmarkdown::render(\"$*.md\")"

%.R: %.Rmd
	Rscript --vanilla -e "knitr::purl(\"$*.Rmd\",output=\"$*.R\",documentation=2)"

clean:
	$(RM) -r check library
	$(RM) src/*.o src/*.so src/symbols.rds vignettes/Rplots.*
	$(RM) -r inst/doc/figure inst/doc/cache
	$(RM) -r *-Ex.Rout *-Ex.timings *-Ex.pdf
	$(RM) $(PKGVERS).tar.gz $(PKGVERS).zip $(PKGVERS).tgz $(PKG).pdf

.SECONDARY:


# ----------------------------------------
# Makefile for clo
# Generated using ontology-starter-kit
# ----------------------------------------
# <do not edit above this line>

# ----------------------------------------
# Standard Constants
# ----------------------------------------
# these can be overwritten on the command line

URIBASE=                    http://purl.obolibrary.org/obo
ONT=                        clo
ONTBASE=                    $(URIBASE)/$(ONT)
SRC =                       $(ONT).owl
ROBOT=                      robot
RELEASEDIR=                 ../..
REPORTDIR=                 reports
SPARQLDIR =                 ../sparql
REPORT_FAIL_ON =            None
OBO_FORMAT_OPTIONS =        
# FAILING: trailing-whitespace nolabels
SPARQL_VALIDATION_CHECKS =  equivalent-classes  owldef-self-reference xref-syntax 
SPARQL_EXPORTS =            basic-report class-count-by-prefix edges xrefs obsoletes synonyms

TODAY   := $(shell date +%Y-%m-%d)

# ----------------------------------------
# Top-level targets
# ----------------------------------------

all: sparql_test all_reports release
release: $(ONT)-base.owl
	cp $^ $(RELEASEDIR)

$(ONT)-base.owl: $(SRC)
	$(ROBOT) remove --input $< --select imports \
		annotate --ontology-iri $(ONTBASE)/$@ --version-iri $(ONTBASE)/releases/$(TODAY)/$@ --output $@.tmp.owl && mv $@.tmp.owl $@

# Full: The full artefacts with imports merged, reasoned
$(ONT)-full.owl: $(SRC)
	$(ROBOT) merge --input $< \
		reason --reasoner ELK \
		relax \
		reduce -r ELK \
		annotate --ontology-iri $(ONTBASE)/$@ --version-iri $(ONTBASE)/releases/$(TODAY)/$@ --output $@.tmp.owl && mv $@.tmp.owl $@

# ----------------------------------------
# Sparql queries: Q/C
# ----------------------------------------

# these live in the ../sparql directory, and have suffix -violation.sparql
# adding the name here will make the violation check live.
# NOTE: these will soon be phased out and replaced by robot-report

#  run all violation checks
SPARQL_VALIDATION_QUERIES = $(foreach V,$(SPARQL_VALIDATION_CHECKS),$(SPARQLDIR)/$V-violation.sparql)
sparql_test: $(SRC)
	$(ROBOT) verify  --catalog catalog-v001.xml -i $< --queries $(SPARQL_VALIDATION_QUERIES) -O reports/

# ----------------------------------------
# ROBOT report
# ----------------------------------------

OBO_REPORT = $(ONT)-obo-report $(ONT)-obo-report
REPORTS = $(OBO_REPORT)
REPORT_FILES = $(patsubst %, $(REPORTDIR)/%.tsv, $(REPORTS))

all_reports: all_reports_onestep $(REPORT_FILES)

reports/%-obo-report.tsv: %.owl
	$(ROBOT) report -i $< --fail-on $(REPORT_FAIL_ON) -o $@

# ----------------------------------------
# Sparql queries: Exports
# ----------------------------------------

SPARQL_EXPORTS_ARGS = $(foreach V,$(SPARQL_EXPORTS),-s $(SPARQLDIR)/$V.sparql reports/$V.tsv)
# This combines all into one single command
all_reports_onestep: $(SRC)
	$(ROBOT) query -f tsv -i $< $(SPARQL_EXPORTS_ARGS)

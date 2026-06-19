# Cell Line Ontology (CLO) Makefile
# Jie Zheng
#
# This Makefile is used to build artifacts for the Cell Line Ontology.
#

### Configuration
#
# prologue:
# <http://clarkgrubb.com/makefile-style-guide#toc2>

MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:

### Definitions

SHELL := /bin/bash
OBO   := http://purl.obolibrary.org/obo
CLO    := $(OBO)/CLO_
TODAY := $(shell date +%Y-%m-%d)

### Directories
#
# This is a temporary place to put things.
build:
	mkdir -p $@


### ROBOT
#
# We use the latest official release version of ROBOT
build/robot.jar: | build
	curl -L -o $@ "https://github.com/ontodev/robot/releases/latest/download/robot.jar"

ROBOT := java -jar build/robot.jar

### Imports
#
# Use Ontofox to import various modules.
build/%_import.owl: src/ontology/Ontofox_input/%_import_input.txt | build/robot.jar build
	curl -s -F file=@$< -o $@ https://ontofox.hegroup.org/service.php

# Use ROBOT to remove external java axioms
src/ontology/imports/RO_import.owl: build/RO_import.owl
	$(ROBOT) remove --input build/RO_import.owl \
	--base-iri 'http://purl.obolibrary.org/obo/RO_' \
	--axioms external \
	--exclude-term BFO:0000062 \
	--exclude-term BFO:0000063 \
	--preserve-structure false \
	--trim false \
	--output $@

src/ontology/imports/%_import.owl: build/%_import.owl
	$(ROBOT) remove --input build/$*_import.owl \
	--base-iri 'http://purl.obolibrary.org/obo/$*_' \
	--base-iri 'http://purl.obolibrary.org/obo/UBPROP_' \
	--axioms external \
	--preserve-structure false \
	--trim false \
	--output $@ 

IMPORT_FILES := $(wildcard src/ontology/imports/*_import.owl)

.PHONY: imports
imports: $(IMPORT_FILES)

### Templates
#
src/ontology/modules/%.owl: src/ontology/templates/%.csv | build/robot.jar
	echo '' > $@
	$(ROBOT) merge \
	--input src/ontology/clo-edit.owl \
	template \
	--template $< \
	--prefix "CLO: http://purl.obolibrary.org/obo/CLO_" \
	--ontology-iri "http://purl.obolibrary.org/obo/clo/$(notdir $@)" \
	--output $@

# Update all modules
MODULE_NAMES := cell-line-cells \
	obsolete
# cellline_ATCC\
# individuals\
# clo_annotationProp\
# clo_objectProp\
# clo_ATCC\
# obsolete

MODULE_FILES := $(foreach x,$(MODULE_NAMES),src/ontology/modules/$(x).owl)

.PHONY: modules
modules: $(MODULE_FILES)

### Build
#
# Here we create a standalone OWL file appropriate for release.
# This involves merging, reasoning, annotating,
# and removing any remaining import declarations.

build/clo_merged.owl: src/ontology/clo-edit.owl | build/robot.jar build
	$(ROBOT) merge \
	--input $< \
	annotate \
	--ontology-iri "$(OBO)/clo/clo_merged.owl" \
	--version-iri "$(OBO)/clo/releases/$(TODAY)/clo_merged.owl" \
	--annotation owl:versionInfo "$(TODAY)" \
	--output build/clo_merged.tmp.owl
	sed '/<owl:imports/d' build/clo_merged.tmp.owl > $@
	rm build/clo_merged.tmp.owl

clo.owl: build/clo_merged.owl
	$(ROBOT) reason \
	--input $< \
	--reasoner ELK \
	annotate \
	--ontology-iri "$(OBO)/clo.owl" \
	--version-iri "$(OBO)/clo/releases/$(TODAY)/clo.owl" \
	--annotation owl:versionInfo "$(TODAY)" \
	--output $@

robot_report.tsv: build/clo_merged.owl
	$(ROBOT) report \
	--input $< \
        --fail-on none \
	--output $@

### 
#
# Full build
.PHONY: all
all: clo.owl robot_report.tsv

# Remove generated files
.PHONY: clean
clean:
	rm -rf build






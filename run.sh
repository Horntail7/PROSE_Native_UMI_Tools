#!/bin/bash

#Change NCORES (default = 8) depending on workload and resources
snakemake -s snakefile --cores 8 --printshellcmds --verbose --keep-going --use-conda


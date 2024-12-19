#!/bin/bash

# # Build QC environment
# mamba env create -f /mnt/omar/pipelines/ont/work/workflow/envs/002_qc.yml

# # Build abundance environment and download databases
# mamba env create -f /mnt/omar/pipelines/ont/work/workflow/envs/003_abundance.yml

# Build pathways environment and download databases
mamba env create -f /mnt/omar/pipelines/ont/work/workflow/envs/004_pathways.yml
mamba activate 004_pathways
metaphlan --install --index mpa_vOct22_CHOCOPhlAnSGB_202403
humann_databases --download chocophlan full /ref/humann/chocophlan
humann_databases --download uniref uniref90_ec_filtered_diamond /ref/humann/uniref
humann_databases --download utility_mapping full /ref/humann/utility_mapping
mamba deactivate

# # Build AMR environment and download databases
# mamba env create -f /mnt/omar/pipelines/ont/work/workflow/envs/005_amr.yml

# # Create tree and multiqc environments
# mamba env create -f /mnt/omar/pipelines/ont/work/workflow/envs/006_tree.yml
# mamba env create -f /mnt/omar/pipelines/ont/work/workflow/envs/010_multiqc.yml
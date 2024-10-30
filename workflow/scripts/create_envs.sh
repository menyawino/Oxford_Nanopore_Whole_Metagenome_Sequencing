#!/bin/bash

# Create environments using Mamba
mamba env create -f /mnt/omar/pipelines/ont/work/workflow/envs/002_qc.yml
mamba env create -f /mnt/omar/pipelines/ont/work/workflow/envs/003_abundance.yml
mamba env create -f /mnt/omar/pipelines/ont/work/workflow/envs/004_pathways.yml
mamba env create -f /mnt/omar/pipelines/ont/work/workflow/envs/005_amr.yml
mamba env create -f /mnt/omar/pipelines/ont/work/workflow/envs/006_tree.yml
mamba env create -f /mnt/omar/pipelines/ont/work/workflow/envs/010_multiqc.yml
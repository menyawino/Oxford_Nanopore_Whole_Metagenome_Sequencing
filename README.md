# Metagenomic Analysis Pipeline

This pipeline is designed for comprehensive metagenomic analysis using long-read sequencing data. It includes steps for quality control, taxonomic classification, phenotype likelihood calculation, functional profiling, antimicrobial resistance detection, phylogenetic tree construction, and multi-sample reporting.

## Tools Used in the Pipeline

### 1. **FastQC**

**Description:**
- FastQC is a quality control tool for high throughput sequence data. It provides a modular set of analyses to assess the quality of raw sequence data.

**Usage:**
- FastQC is used to generate quality reports for raw and trimmed sequence data.

### 2. **Fastp**

**Description:**
- Fastp is a tool designed to provide fast all-in-one preprocessing for FASTQ files. It includes quality control, adapter trimming, and filtering.

**Usage:**
- Fastp is used for adapter trimming and quality filtering of raw sequence data.

### 3. **Kraken2**

**Description:**
- Kraken2 is a taxonomic classification system that assigns taxonomic labels to short DNA sequences. It uses exact k-mer matches to classify sequences.

**Usage:**
- Kraken2 is used for taxonomic classification of metagenomic reads.

### 4. **Bracken**

**Description:**
- Bracken (Bayesian Reestimation of Abundance with KrakEN) is a highly accurate statistical method that computes the abundance of species in DNA sequences from a metagenomics sample.

**Usage:**
- Bracken is used to re-estimate species abundance from Kraken2 output.

### 5. **HUMAnN3**

**Description:**
- HUMAnN3 (The HMP Unified Metabolic Analysis Network) is a pipeline for efficiently and accurately profiling the presence/absence and abundance of microbial pathways in a community from metagenomic or metatranscriptomic sequencing data.

**Usage:**
- HUMAnN3 is used for functional profiling of metagenomic samples.

### 6. **ResFinder**

**Description:**
- ResFinder is a tool for identifying antimicrobial resistance genes in whole genome sequencing data.

**Usage:**
- ResFinder is used to detect antimicrobial resistance genes in metagenomic samples.

### 7. **Tree Construction Script**

**Description:**
- A custom script is used to construct phylogenetic trees based on the taxonomic classification data.

**Usage:**
- The script generates phylogenetic trees to visualize the evolutionary relationships between the identified species.

### 8. **Custom Python Script for Phenotype Likelihood Calculation**

**Description:**
- A custom Python script is used to calculate the likelihood of various phenotypes based on species abundance data from Bracken and a phenotype database.

**Usage:**
- The script compares Bracken output with a phenotype database to calculate and rank phenotype likelihoods.

### 9. **MultiQC**

**Description:**
- MultiQC is a tool to aggregate results from bioinformatics analyses across many samples into a single report. It parses summary statistics from various tools and generates a comprehensive report.

**Usage:**
- MultiQC is used to generate a final report that includes quality control metrics, taxonomic classification results, functional profiling, antimicrobial resistance detection, and phenotype likelihoods.

## Pipeline Steps

### 1. **Quality Control**

**Tools:**
- FastQC
- Fastp

**Description:**
- Raw sequence data undergoes quality control using FastQC to generate initial quality reports.
- Fastp is used to trim adapters and filter low-quality reads.

### 2. **Taxonomic Classification**

**Tools:**
- Kraken2
- Bracken

**Description:**
- Kraken2 is used to classify reads taxonomically.
- Bracken re-estimates species abundance based on Kraken2 output.

### 3. **Functional Profiling**

**Tools:**
- HUMAnN3

**Description:**
- HUMAnN3 is used to profile the presence/absence and abundance of microbial pathways in the metagenomic samples.

### 4. **Antimicrobial Resistance Detection**

**Tools:**
- ResFinder

**Description:**
- ResFinder is used to detect antimicrobial resistance genes in the metagenomic samples.

### 5. **Phylogenetic Tree Construction**

**Tools:**
- Custom Tree Construction Script

**Description:**
- A custom script constructs phylogenetic trees based on the taxonomic classification data to visualize evolutionary relationships.

### 6. **Phenotype Likelihood Calculation**

**Tools:**
- Custom Python Script

**Description:**
- A custom script calculates the likelihood of various phenotypes based on species abundance data from Bracken and a phenotype database.
- The script normalizes abundance values and determines a high likelihood threshold based on the 90th percentile of the 'abudance mean' values in the phenotype database.

### 7. **Multi-Sample Reporting**

**Tools:**
- MultiQC

**Description:**
- MultiQC aggregates results from FastQC, Fastp, Kraken2, Bracken, HUMAnN3, ResFinder, and the custom phenotype likelihood script into a single comprehensive report.

## Example Output

### Phenotype Likelihood Calculation

The output file contains the following columns:
- **Phenotype:** The identifier of the phenotype.
- **Likelihood:** The calculated likelihood value.
- **Term:** The descriptive term for the phenotype.
- **High Likelihood:** A boolean indicating whether the likelihood is considered high based on the threshold.
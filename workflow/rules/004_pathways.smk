#########################################
# Rule 6: Functional Profiling with HUMAnN3
#########################################
rule humann_functional_profiling:
    input:
        fastq = "results/002_qc/merged/{sample}_merged.fastq.gz"
    output:
        gene_families = "results/004_pathways/humann/{sample}/{sample}_gene_families.tsv",
        pathways_abundance = "results/004_pathways/humann/{sample}/{sample}_pathways_abundance.tsv",
        pathways_coverage = "results/004_pathways/humann/{sample}/{sample}_pathways_coverage.tsv"
    params:
        humann_nuc_db = config["humann_nuc_db"],
        humann_prot_db = config["humann_prot_db"]
    threads: 
        config["threads"]
    conda:
        "humann_env"
    benchmark:
        "benchmark/004_pathways/humann/{sample}.time"
    log:
        "logs/004_pathways/humann/{sample}.log"
    shell:
        """
        humann --input {input.fastq} \
        --output results/004_pathways/humann/{wildcards.sample} \
        --threads {threads} \
        --nucleotide-database {params.humann_nuc_db} \
        --protein-database {params.humann_prot_db} \
        --metaphlan-options "-t rel_ab_w_read_stats" \
        #faster debugging purposes --bypass-translated-search \
        --resume \
        > {log} 2>&1
        """
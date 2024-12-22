#########################################
# Rule: Functional Profiling with HUMAnN3
#########################################
rule humann_functional_profiling:
    input:
        fastq = "results/002_qc/merged/{sample}_merged.fastq.gz"
        # fastq = rules.trim_adapters_fastp.output.merged_fastq
    output:
        gene_families = "results/004_pathways/humann/{sample}/{sample}_gene_families.tsv",
        pathways_abundance = "results/004_pathways/humann/{sample}/{sample}_pathways_abundance.tsv",
        pathways_coverage = "results/004_pathways/humann/{sample}/{sample}_pathways_coverage.tsv"
    params:
        humann_nuc_db = config["humann_nuc_db"],
        humann_prot_db = config["humann_prot_db"],
        outdir = "results/004_pathways/humann/{sample}"
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
        --output {params.outdir} \
        --threads {threads} \
        --nucleotide-database {params.humann_nuc_db} \
        --protein-database {params.humann_prot_db} \
        # --bypass-translated-search \
        --resume \
        --bowtie-options "--very-sensitive-local " \
        &> {log}
        """

#########################################
# Rule: Split Stratified Table
#########################################
rule humann_split_stratified_table:
    input:
        gene_families = rules.humann_functional_profiling.output.gene_families,
        pathways_abundance = rules.humann_functional_profiling.output.pathways_abundance,
        pathways_coverage = rules.humann_functional_profiling.output.pathways_coverage
    output:
        gene_families_split = "results/004_pathways/humann/{sample}/{sample}_gene_families_split.tsv",
        pathways_abundance_split = "results/004_pathways/humann/{sample}/{sample}_pathways_abundance_split.tsv",
        pathways_coverage_split = "results/004_pathways/humann/{sample}/{sample}_pathways_coverage_split.tsv"
    params:
        outdir = "results/004_pathways/humann/{sample}"
    threads:
        config["threads"]
    conda:
        "humann_env"
    benchmark:
        "benchmark/004_pathways/humann/{sample}_split_stratified_table.time"
    log:
        "logs/004_pathways/humann/{sample}_split_stratified_table.log"
    shell:
        """
        humann_split_stratified_table --input {input.gene_families} --output {params.outdir} &> {log}
        humann_split_stratified_table --input {input.pathways_abundance} --output {params.outdir} &> {log}
        humann_split_stratified_table --input {input.pathways_coverage} --output {params.outdir} &> {log}
        """

#########################################
#  Rule: Pathway conversion to KEGG   #
#########################################
rule humann_kegg_pathways:
    input:
        genefamilies = rules.humann_functional_profiling.output.gene_families,
    output:
        kegg_orthologs = "results/004_pathways/humann/{sample}/{sample}_genefamilies_uniref90_kegg_orthologs.tsv",
        kegg_pathways = "results/004_pathways/humann/{sample}/{sample}_kegg_pathways.tsv"
    params:
        humann_kegg_db = config["humann_kegg_db"]
    threads:
        config["threads"]
    conda:
        "humann_env"
    params:
        outdir = "results/004_pathways/humann/{sample}"
    benchmark:
        "benchmark/004_pathways/humann/{sample}_kegg_pathways.time"
    log:
        "logs/004_pathways/humann/{sample}_kegg_pathways.log"
    shell:
        """
        humann_regroup_table --input {input.genefamilies} \
        --group uniref90_kegg \
        --output {output.kegg_orthologs} \
        &> {log}

        humann --input {output.kegg_orthologs} \
        --output {params.outdir} \
        --pathways-database {params.humann_kegg_db} \
        &> {log}
        """
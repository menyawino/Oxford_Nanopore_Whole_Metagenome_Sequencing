#########################################
# Rule: Functional Profiling with HUMAnN3
#########################################
rule humann_functional_profiling:
    input:
        fastq = "results/002_qc/merged/{sample}_merged.fastq.gz"
        # fastq = rules.trim_adapters_fastp.output.merged_fastq
    output:
        gene_families = "results/004_pathways/humann/{sample}/{sample}_merged_2_genefamilies.tsv",
        pathways_abundance = "results/004_pathways/humann/{sample}/{sample}_merged_4_pathabundance.tsv",
        reactions_abundance = "results/004_pathways/humann/{sample}/{sample}_merged_3_reactions.tsv"
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
        "logs/004_pathways/humann/{sample}/{sample}.log"
    shell:
        """
        humann --input {input.fastq} \
        --output {params.outdir} \
        --threads {threads} \
        --nucleotide-database {params.humann_nuc_db} \
        --protein-database {params.humann_prot_db} \
        --resume \
        --bowtie-options "--very-sensitive-local " \
        &> {log}
        """

#########################################
# Rule: Normalize Gene Families Table
#########################################
rule humann_renorm_table:
    input:
        gene_families = rules.humann_functional_profiling.output.gene_families
    output:
        gene_families_relab = "results/004_pathways/humann/{sample}/{sample}_merged_2_genefamilies_relab.tsv"
    conda:
        "humann_env"
    threads:
        config["threads"]
    benchmark:
        "benchmark/004_pathways/humann/{sample}_renorm_table.time"
    log:
        "logs/004_pathways/humann/{sample}/{sample}_renorm_table.log"
    shell:
        """
        humann_renorm_table --input {input.gene_families} \
        --output {output.gene_families_relab} \
        --units relab \
        &> {log}
        """

#########################################
#  Rule: Pathway conversion to KEGG   #
#########################################
rule humann_kegg_pathways:
    input:
        genefamilies = rules.humann_functional_profiling.output.gene_families
    output:
        kegg_orthologs = "results/004_pathways/humann/{sample}/{sample}_genefamilies_uniref90_kegg_orthologs.tsv",
        kegg_pathways = "results/004_pathways/humann/{sample}/{sample}_kegg_pathways.tsv"
    params:
        humann_kegg_db = config["humann_kegg_db"]
    threads:
        config["threads"]
    conda:
        "humann_env"
    benchmark:
        "benchmark/004_pathways/humann/{sample}/{sample}_kegg_pathways.time"
    log:
        "logs/004_pathways/humann/{sample}/{sample}_kegg_pathways.log"
    shell:
        """
        humann_regroup_table --input {input.genefamilies} \
        --group uniref90_ko \
        --output {output.kegg_orthologs} \
        &> {log}

        humann --input {output.kegg_orthologs} \
        --output results/004_pathways/humann/{wildcards.sample} \
        --pathways-database {params.humann_kegg_db} \
        &> {log}
        """
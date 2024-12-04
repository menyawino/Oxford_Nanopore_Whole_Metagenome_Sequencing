#########################################
# Rule 6: Functional Profiling with HUMAnN3
#########################################
rule humann_functional_profiling:
    input:
        fastq = rules.trim_adapters_fastp.output.merged_fastq
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

usage: humann_renorm_table [-h] [-i INPUT]
                           [-u {cpm,}]
                           [-m {community,levelwise}]
                           [-s {y,n}] [-p]
                           [-o OUTPUT]

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
    benchmark:
        "benchmark/004_pathways/humann/{sample}_kegg_pathways.time"
    log:
        "logs/004_pathways/humann/{sample}_kegg_pathways.log"
    shell:
        """
        humann_regroup_table --input {input.genefamilies} \
        --group uniref90_kegg \
        --output {output.kegg_orthologs} \
        > {log} 2>&1

        humann --input {output.kegg_orthologs} \
        --output {output.kegg_pathways} \
        --pathways-database {params.humann_kegg_db} \
        >> {log} 2>&1
        """


#######################################
# EXPERIMENTAL Rule: Compare Bracken Output to Phenotype Database
#######################################
rule compare_phenotypes:
    input:
        bracken_output = rules.reestimate_abundance.output.bracken_output,
        phenotype_db = "workflow/config/phenotype_summary.tsv"
    output:
        phenotype_likelihood = "results/004_pathways/disease_phenotypes/{sample}_phenotype_likelihood.txt"
    params:
        script = "scripts/calculate_phenotype_likelihood.py"
    threads:
        config["threads"]
    conda:
        "humann_env"
    benchmark:
        "benchmark/004_pathways/disease_phenotypes/{sample}.time"
    log:
        "logs/004_pathways/disease_phenotypes/{sample}.log"
    shell:
        """
        python {params.script} \
        --bracken {input.bracken_output} \
        --phenotypes {input.phenotype_db} \
        --output {output.phenotype_likelihood} \
        --threads {threads} \
        > {log} 2>&1
        """


#########################################
# EXPERIMENTAL Rule: Calculate Taxa Contribution to Pathways
#########################################
rule calculate_taxa_contribution:
    input:
        pathways_abundance = rules.humann_functional_profiling.output.pathways_abundance,
    output:
        taxa_contribution = "results/004_pathways/humann/{sample}/{sample}_taxa_contribution.tsv"
    params:
        script = "scripts/calculate_taxa_contribution.py"
    threads:
        config["threads"]
    conda:
        "humann_env"
    benchmark:
        "benchmark/004_pathways/humann/{sample}_taxa_contribution.time"
    log:
        "logs/004_pathways/humann/{sample}_taxa_contribution.log"
    shell:
        """
        python {params.script} \
        --input {input.pathways_abundance} \
        --output {output.taxa_contribution} \
        > {log} 2>&1
        """
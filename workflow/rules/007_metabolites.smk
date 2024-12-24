
#######################################
# Rule: Concatenate Gene Families
#######################################
rule concatenate_gene_families:
    input:
        gene_families = expand("results/004_pathways/humann/{sample}/{sample}_merged_2_genefamilies_relab.tsv", sample=config["samples"])
    output:
        concatenated_gene_families = "results/004_pathways/humann/concatenated_gene_families.tsv"
    conda:
        "humann_env"
    threads:
        config["threads"]
    benchmark:
        "benchmark/004_pathways/humann/concatenate_gene_families.time"
    log:
        "logs/004_pathways/humann/concatenate_gene_families.log"
    shell:
        """
        python scripts/concatenate_gene_families.py \
        --input {input.gene_families} \
        --output {output.concatenated_gene_families} \
        &> {log}
        """

#######################################
# Rule: Metabolite Prediction with MelonnPan
#######################################
rule melonnpan_prediction:
    input:
        pathways_abundance = rules.concatenate_gene_families.output.concatenated_gene_families
    output:
        metabolites = "results/004_pathways/melonnpan/{sample}/MelonnPan_Predicted_Metabolites.txt",
        rtsi = "results/004_pathways/melonnpan/{sample}/MelonnPan_RTSI.txt"
    conda:
        "melonpann_env"
    threads:
        config["threads"]
    benchmark:
        "benchmark/004_pathways/melonnpan/{sample}.time"
    params:
        predict_metabolites = config["predict_metabolites"]
    log:
        "logs/004_pathways/melonnpan/{sample}.log"
    shell:
        """
        Rscript {params.predict_metabolites} \
        -i {input.pathways_abundance} \
        -o results/004_pathways/melonnpan/{wildcards.sample}/ \
        &> {log}
        """
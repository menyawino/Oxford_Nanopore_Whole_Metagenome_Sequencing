#######################################
# Rule: Map KO to Metabolites
#######################################
rule map_ko_to_metabolites:
    input:
        kegg_reactions = "results/004_pathways/humann/{sample}/{sample}_kegg_3_reactions.tsv"
    output:
        metabolites = "results/005_metabolites/{sample}/{sample}_metabolites.tsv"
    conda:
        "humann_env"
    threads:
        config["threads"]
    benchmark:
        "benchmark/005_metabolites/{sample}/{sample}_map_ko_to_metabolites.time"
    log:
        "logs/005_metabolites/{sample}/{sample}_map_ko_to_metabolites.log"
    shell:
        """
        python scripts/reactions_to_meatbolites.py \
        --input {input.kegg_reactions} \
        --output {output.metabolites} \
        --threads {threads} \
        &> {log}
        """
#######################################
# Rule: Phylogenetic Tree Construction (Tree.py)
#######################################
rule tree_build:
    input:
        msa = rules.classify_taxa.output.kraken_report
    output:
        tree_txt = "results/006_tree/tree/{sample}_tree.txt",
        tree_json = "results/006_tree/tree/{sample}_tree.json"
    conda:
        "006_tree"
    benchmark:
        "benchmark/006_tree/tree_build/{sample}.time"
    log:
        "logs/006_tree/tree_build/{sample}.log"
    shell:
        """
        python scripts/tree.py \
        -in {input.msa} \
        -out {output.tree_txt} \
        --json-out {output.tree_json} \
        > {log} 2>&1
        """

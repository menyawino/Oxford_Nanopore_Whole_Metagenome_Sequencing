#######################################
# Rule: Assemble contigs with SPAdes
#######################################
rule assemble_spades:
    input:
        fastq = "results/002_qc/merged/{sample}_merged.fastq.gz"
    output:
        contigs = "results/003_assembly/{sample}/contigs.fasta"
    conda:
        "ont"
    threads:
        config["threads"]
    benchmark:
        "benchmark/003_assembly/spades/{sample}.time"
    log:
        "logs/003_assembly/spades/{sample}.log"
    shell:
        """
        spades.py \
        --s1 {input.fastq} \
        -o results/003_assembly/{wildcards.sample} \
        --threads {threads} \
        > {log} 2>&1
        """

# #######################################
# # Rule: MSA with MAFFT
# #######################################
# rule msa_mafft:
#     input:
#         contigs = rules.assemble_spades.output.contigs
#     output:
#         msa = "results/006_tree/msa/{sample}_msa.fasta"
#     conda:
#         "ont"
#     threads: 
#         config["threads"]
#     benchmark:
#         "benchmark/006_tree/msa/{sample}.time"
#     log:
#         "logs/006_tree/msa/{sample}.log"
#     shell:
#         """
#         # Run MAFFT on the assembled contigs
#         mafft --auto \
#         --retree 0 --maxiterate 0 \
#         --thread {threads} \
#         {input.contigs} > {output.msa} \
#         2> {log}
#         """

#######################################
# Rule: MSA with Clustal Omega
#######################################
rule msa_clustalo:
    input:
        contigs = rules.assemble_spades.output.contigs
    output:
        msa = "results/006_tree/msa/{sample}_msa.fasta"
    conda:
        "ont"
    threads: 
        config["threads"]
    benchmark:
        "benchmark/006_tree/msa/{sample}.time"
    log:
        "logs/006_tree/msa/{sample}.log"
    shell:
        """
        # Run Clustal Omega for multiple sequence alignment
        clustalo -i {input.contigs} \
        -o {output.msa} \
        --seqtype=DNA \
        --infmt=fa \
        --outfmt=fa \
        --threads={threads} \
        --force \
        --verbose \
        --iter=1 \
        --log {log} \
        >> {log} 2>&1
        """

#######################################
# Rule: MSA with MUSCLE
#######################################
rule msa_muscle:
    input:
        contigs = rules.assemble_spades.output.contigs
    output:
        msa = "results/006_tree/msa/{sample}_msa.fasta"
    conda:
        "msa_tools"
    threads: 
        config["threads"]
    benchmark:
        "benchmark/006_tree/msa/{sample}.time"
    log:
        "logs/006_tree/msa/{sample}.log"
    shell:
        """
        # Run MUSCLE for multiple sequence alignment
        muscle -align {input.contigs} -output {output.msa} -maxiters 2 -diags1 -sv -distance1 kbit20_3 -threads {threads} > {log} 2>&1
        """

#######################################
# Rule: Phylogenetic Tree Construction (FastTree)
#######################################
rule tree_fasttree:
    input:
        msa = rules.msa_clustalo.output.msa
    output:
        tree = "results/006_tree/tree/{sample}_tree.nwk"
    conda:
        "ont"
    benchmark:
        "benchmark/006_tree/tree/{sample}.time"
    log:
        "logs/006_tree/tree/{sample}.log"
    shell:
        """
        fasttree {input.msa} > {output.tree} \
        2> {log}
        """




#######################################
# Rule: Phylogenetic Tree Construction (Tree.py)
#######################################
rule tree_build:
    input:
        msa = rules.msa_clustalo.output.msa
    output:
        tree_txt = "results/006_tree/tree/{sample}_tree.txt",
        tree_json = "results/006_tree/tree/{sample}_tree.json"
    conda:
        "ont"
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

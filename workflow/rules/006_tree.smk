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
        # Check if the input FASTA file is empty or invalid
        if [ ! -s {input.contigs} ]; then
            echo "Error: Input FASTA file is empty or invalid" >&2
            exit 1
        fi

        # Run Clustal Omega for multiple sequence alignment
        clustalo -i {input.contigs} \
        -o {output.msa} \
        --threads={threads} \
        --force \
        > {log} 2>&1
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
        fasttree {input.msa} > {output.tree} 2> {log}
        """
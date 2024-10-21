#######################################
# Rule 3: Trim adapters using FastP
#######################################
rule trim_adapters_fastp:
    message:
        "Trimming adapters from {wildcards.sample}"
    input:
        fastq1 = "samples/fastq/{sample}_1.fastq.gz",
        fastq2 = "samples/fastq/{sample}_2.fastq.gz"
    output:
        html = "results/002_qc/trimmed/{sample}_fastp.html",
        merged_fastq = "results/002_qc/merged/{sample}_merged.fastq.gz"
    conda:
        "ont"
    threads: 
        config["threads"]
    benchmark:
        "benchmark/002_qc/fastp/{sample}.time"
    log:
        "logs/002_qc/fastp/{sample}.log"
    shell:
        """
        fastp \
        -i {input.fastq1} \
        -I {input.fastq2} \
        -m --merged_out {output.merged_fastq} \
        --include_unmerged \
        -j {log} \
        -w {threads} \
        -h {output.html} \
        > {log} 2>&1
        """

#######################################
# Rule: MSA with MAFFT
#######################################
rule msa_mafft:
    input:
        fastq = "results/002_qc/merged/{sample}_merged.fastq.gz"
    output:
        msa = "results/005_tree/msa/{sample}_msa.fasta"
    conda:
        "ont"
    threads: 
        config["threads"]
    benchmark:
        "benchmark/005_tree/msa/{sample}.time"
    log:
        "logs/005_tree/msa/{sample}.log"
    shell:
        """
        mafft \
        --auto \
        --thread {threads} \
        {input.fastq} > {output.msa} \
        2> {log}
        """

#######################################
# Rule: Tree building with fasttree
#######################################
rule tree_fasttree:
    input:
        msa = "results/005_tree/msa/{sample}_msa.fasta"
    output:
        tree = "results/005_tree/tree/{sample}_tree.nwk"
    conda:
        "ont"
    benchmark:
        "benchmark/005_tree/tree/{sample}.time"
    log:
        "logs/005_tree/tree/{sample}.log"
    shell:
        """
        fasttree {input.msa} > {output.tree} 2> {log}
        """

#######################################
# Rule 8: MultiQC
#######################################
rule multiqc:
    input:
        fastqc = expand("results/002_qc/{sample}_{read}_fastqc.zip", sample=config["samples"], read=config["reads"]),
        fastp = expand("results/002_qc/trimmed/{sample}_{read}_trimmed.fastq.gz", sample=config["samples"], read=config["reads"]),
        # kraken = expand("results/003_abundance/kraken2/reports/{sample}_kraken_report.txt", sample=config["samples"]),
        # bracken = expand("results/003_abundance/bracken/{sample}_bracken_output.txt", sample=config["samples"]),
        # humann = expand("results/004_pathways/humann/{sample}_pathways_abundance.tsv", sample=config["samples"]),
        resfinder = expand("results/005_amr/resfinder/{sample}/ResFinder_results.txt", sample=config["samples"]),
        tree = expand("results/005_tree/tree/{sample}_tree.nwk", sample=config["samples"]),
    output:
        html = "results/multiqc/multiqc_report.html"
    conda:
        "ont"
    benchmark:
        "benchmark/multiqc/multiqc.time"
    log:
        "logs/multiqc/multiqc.log"
    shell:
        """
        multiqc -f \
        -o results/multiqc/ \
        results/ logs/ benchmark/ \
        > {log} 2>&1
        """
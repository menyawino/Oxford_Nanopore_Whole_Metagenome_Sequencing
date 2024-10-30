#######################################
# Rule 8: MultiQC
#######################################
rule multiqc:
    input:
        # fastqc = expand("results/002_qc/fastqc/{sample}_{read}_fastqc.zip", sample=config["samples"], read=config["reads"]),
        # fastp = expand("results/002_qc/trimmed/{sample}_{read}_trimmed.fastq.gz", sample=config["samples"], read=config["reads"]),
        # kraken = expand("results/003_abundance/kraken2/reports/{sample}_kraken_report.txt", sample=config["samples"]),
        # bracken = expand("results/003_abundance/bracken/{sample}_bracken_output.txt", sample=config["samples"]),
        # humann = expand("results/004_pathways/humann/{sample}_pathways_abundance.tsv", sample=config["samples"]),
        # resfinder = expand("results/005_amr/resfinder/{sample}/ResFinder_results.txt", sample=config["samples"]),
        tree = expand(rules.tree_build.output.tree_txt, sample=config["samples"])
    output:
        html = "results/multiqc/multiqc_report.html"
    conda:
        "multiqc_env"
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
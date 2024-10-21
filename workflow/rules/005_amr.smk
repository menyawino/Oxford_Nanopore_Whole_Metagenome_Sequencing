#######################################
# Rule: Antimicrobial Resistance Detection (AMRFinder)
#######################################

rule amr_detection:
    message:
        "Detecting antimicrobial resistance genes in {wildcards.sample}"
    input:
        merged_fastq = "results/002_qc/merged/{sample}_merged.fastq.gz"
    output:
        amr_results = "results/005_amr/{sample}_amr_results.tsv"
    conda:
        "ont"
    threads: 
        config["threads"]
    benchmark:
        "benchmark/005_amr/{sample}.time"
    log:
        "logs/005_amr/{sample}.log"
    shell:
        """
        amrfinder \
        -n {threads} \
        -o {output.amr_results} \
        {input.merged_fastq} \
        > {log} 2>&1
        """

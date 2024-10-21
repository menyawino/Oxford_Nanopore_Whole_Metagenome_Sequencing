# #######################################
# # Rule: Antimicrobial Resistance Detection (AMRFinder)
# #######################################

# rule amr_detection:
#     message:
#         "Detecting antimicrobial resistance genes in {wildcards.sample}"
#     input:
#         merged_fastq = "results/002_qc/merged/{sample}_merged.fastq.gz"
#     output:
#         amr_results = "results/005_amr/amrfinder/{sample}_amr_results.tsv"
#     conda:
#         "ont"
#     threads: 
#         config["threads"]
#     benchmark:
#         "benchmark/005_amr/amrfinder/{sample}.time"
#     log:
#         "logs/005_amr/amrfinder/{sample}.log"
#     shell:
#         """
#         amrfinder \
#         -n {threads} \
#         -o {output.amr_results} \
#         {input.merged_fastq} \
#         > {log} 2>&1
#         """

#######################################
# Rule: Antimicrobial Resistance Detection (ResFinder)
#######################################

rule resfinder_detection:
    message:
        "Detecting antimicrobial resistance genes in {wildcards.sample}"
    input:
        merged_fastq = "results/002_qc/merged/{sample}_merged.fastq.gz"
    output:
        resfinder_results = "results/005_amr/resfinder/{sample}/ResFinder_results.txt"
    conda:
        "ont"
    threads: 
        config["threads"]
    benchmark:
        "benchmark/005_amr/resfinder/{sample}.time"
    log:
        "logs/005_amr/resfinder/{sample}.log"
    shell:
        """
        run_resfinder.py \
        -o results/005_amr/resfinder/{wildcards.sample} \
        -ifq {input.merged_fastq} \
        -acq \
        > {log} 2>&1
        """
#######################################
# Rule 1: Basecalling with Guppy
#######################################
rule basecall:
    input:
        fast5_dir = config["fast5_dir"]
    output:
        fastq = "results/fastq/{sample}.fastq"
    conda:
        "ont"
    threads:
        config["threads"]
    benchmark:
        "benchmark/basecall/{sample}.time"
    log:
        "logs/basecall/{sample}.log"
    shell:
        """
        guppy_basecaller -i {input.fast5_dir} -s results/fastq --flowcell FLO-MIN106 --kit SQK-LSK109 --fast5_out none
        """
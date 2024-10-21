#######################################
# Rule 2: Quality Control using FastQC
#######################################
rule qc_fastq:
    message:
        "Running FastQC on {wildcards.sample}_{wildcards.read}"
    input:
        fastq = "samples/fastq/{sample}_{read}.fastq.gz"
    output:
        html = "results/002_qc/{sample}_{read}_fastqc.html",
        zip = "results/002_qc/{sample}_{read}_fastqc.zip"
    conda:
        "ont"
    benchmark:
        "benchmark/002_qc/fastqc/{sample}_{read}.time"
    log:
        "logs/002_qc/fastqc/{sample}_{read}.log"
    shell:
        """
        fastqc {input.fastq} \
        -o results/002_qc/ \
        > {log} 2>&1
        """


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
        trimmed_fastq1 = "results/002_qc/trimmed/{sample}_1_trimmed.fastq.gz",
        trimmed_fastq2 = "results/002_qc/trimmed/{sample}_2_trimmed.fastq.gz",
        html = "results/002_qc/trimmed/{sample}_fastp.html",
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
        -o {output.trimmed_fastq1} \
        -O {output.trimmed_fastq2} \
        -j {log} \
        -w {threads} \
        -h {output.html} \
        > {log} 2>&1
        """


#######################################
#        Rule 4: Merge Reads          #
#######################################
rule merge_reads:
    message:
        "Merging reads from {wildcards.sample}"
    input:
        fastq1 = "results/002_qc/trimmed/{sample}_1_trimmed.fastq.gz",
        fastq2 = "results/002_qc/trimmed/{sample}_2_trimmed.fastq.gz"
    output:
        merged_fastq = "results/002_qc/merged/{sample}_merged.fastq.gz"
    benchmark:
        "benchmark/002_qc/merged/{sample}.time"
    log:
        "logs/002_qc/merged/{sample}.log"
    shell:
        """
        cat {input.fastq1} {input.fastq2} \
        > {output.merged_fastq}
        """
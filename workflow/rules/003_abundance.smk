#######################################
# Rule 4: Taxonomic Classification with Kraken2
#######################################
rule classify_taxa:
    input:
        fastq = rules.trim_adapters_fastp.output.merged_fastq
    output:
        kraken_report = "results/003_abundance/kraken2/reports/{sample}_kraken_report.txt",
        kraken_output = "results/003_abundance/kraken2/outputs/{sample}_kraken_output.txt"
    params:
        kraken_db = config["kraken_db"]
    conda:
        "ont"
    threads: 
        config["threads"]
    resources:
        mem_mb = 37000
    benchmark:
        "benchmark/003_abundance/kraken2/{sample}.time"
    log:
        "logs/003_abundance/kraken2/{sample}.log"
    shell:
        """
        kraken2 --db {params.kraken_db} \
        --output {output.kraken_output} \
        --report {output.kraken_report} \
        --threads {threads} \
        --quick \
        <(gunzip -c {input.fastq}) \
        > {log} 2>&1
        """

#######################################
# Rule 5: Bracken Re-estimation
#######################################
rule reestimate_abundance:
    input:
        kraken_report = rules.classify_taxa.output.kraken_report
    output:
        bracken_output = "results/003_abundance/bracken/{sample}_bracken_output.txt"
    params:
        bracken_db = config["bracken_db"],
        level = "S"  # For species level
    conda:
        "ont"
    benchmark:
        "benchmark/003_abundance/bracken/{sample}.time"
    log:
        "logs/003_abundance/bracken/{sample}.log"
    shell:
        """
        bracken -d {params.bracken_db} \
        -i {input.kraken_report} \
        -o {output.bracken_output} \
        -l {params.level} \
        -r 150 \
        > {log} 2>&1
        """
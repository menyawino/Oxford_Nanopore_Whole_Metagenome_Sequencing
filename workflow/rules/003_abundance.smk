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
        mem_mb = 80000 #Very ram intensive for long reads input, for short reads, reduce to 40000
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
        &> {log}
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
    threads: 
        config["threads"]
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
        -t {threads} \
        &> {log}
        """

#######################################
# Rule 6: Alpha Diversity Estimation
#######################################
rule estimate_alpha_diversity:
    input:
        bracken_output = rules.reestimate_abundance.output.bracken_output
    output:
        alpha_diversity = "results/003_abundance/alpha_diversity/{sample}_alpha_diversity.txt"
    params:
        alpha_diversity = config["003_alpha_diversity"],
        alpha_type = "Sh"  # Default to Shannon's diversity
    conda:
        "ont"
    benchmark:
        "benchmark/003_abundance/alpha_diversity/{sample}.time"
    log:
        "logs/003_abundance/alpha_diversity/{sample}.log"
    shell:
        """
        python {params.alpha_diversity} \
        -f {input.bracken_output} \
        -a {params.alpha_type} \
        > {output.alpha_diversity} \
        2> {log}
        """


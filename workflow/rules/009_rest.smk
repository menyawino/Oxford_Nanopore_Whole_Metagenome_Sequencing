

#######################################
# Rule 3: Trim adapters using Porechop
#######################################
# rule trim_adapters:
#     input:
#         fastq = "samples/fastq/{sample}_{read}.fastq.gz"
#     output:
#         trimmed_fastq = "results/trimmed/{sample}_{read}_trimmed.fastq.gz"
#     conda:
#         "ont"
#     threads: 
#         config["threads"]
#     benchmark:
#         "benchmark/porechop/{sample}_{read}.time"
#     log:
#         "logs/porechop/{sample}_{read}.log"
#     shell:
#         """
#         porechop -i {input.fastq} \
#         -o {output.trimmed_fastq} \
#         --threads {threads} \
#         | gzip \
#         > {log} 2>&1
#         """


#######################################
# Rule 6: Functional Profiling with HUMAnN3
#######################################
# rule humann_functional_profiling:
#     input:
#         fastq = "results/trimmed/{sample}_trimmed.fastq"
#     output:
#         gene_families = "results/humann/{sample}_gene_families.tsv",
#         pathways_abundance = "results/humann/{sample}_pathways_abundance.tsv",
#         pathways_coverage = "results/humann/{sample}_pathways_coverage.tsv"
#     params:
#         humann_nuc_db = config["humann_nuc_db"],
#         humann_prot_db = config["humann_prot_db"]
#     threads: 
#         config["threads"]
#     conda:
#         "humann_env"
#     benchmark:
#         "benchmark/humann/{sample}.time"
#     log:
#         "logs/humann/{sample}.log"
#     shell:
#         """
#         humann --input {input.fastq} \
#         --output results/humann/{wildcards.sample} \
#         --threads {threads} \
#         --nucleotide-database {params.humann_nuc_db} \
#         --protein-database {params.humann_prot_db} \
#         --resume \
#         > {log} 2>&1
#         """

# #######################################
# # Rule 7: Antimicrobial Resistance Detection (AMRFinder)
# #######################################
# rule amr_detection:
#     input:
#         fastq = "results/trimmed/{sample}_trimmed.fastq"
#     output:
#         amr_output = "results/amr/{sample}_amr_output.tsv"
#     conda:
#         "ont"
#     shell:
#         """
#         amrfinder -n {input.fastq} -o {output.amr_output}
#         """

# #######################################
# # Rule 8: Disease Risk Associations with MaAsLin2
# #######################################
# rule disease_association:
#     input:
#         taxonomy_profile = "results/bracken/{sample}_bracken_output.txt",
#         metadata = config["metadata_file"]
#     output:
#         association_output = "results/maaslin2/{sample}_disease_association.tsv"
#     conda:
#         "ont"
#     shell:
#         """
#         maaslin2 --input_data {input.taxonomy_profile} --input_metadata {input.metadata} --output results/maaslin2
#         """

# #######################################
# # Rule 9: Gut Health Score Calculation
# #######################################
# rule gut_health_score:
#     input:
#         taxonomy_profile = "results/bracken/{sample}_bracken_output.txt",
#         pathways_abundance = "results/humann/{sample}_pathways_abundance.tsv"
#     output:
#         health_score = "results/health/{sample}_gut_health_score.txt"
#     conda:
#         "ont"
#     script:
#         "scripts/gut_health_score.py"

# #######################################
# # Rule 10: Nutritional Recommendations
# #######################################
# rule nutritional_recommendations:
#     input:
#         functional_profile = "results/humann/{sample}_pathways_abundance.tsv",
#         health_score = "results/health/{sample}_gut_health_score.txt"
#     output:
#         recommendations = "results/recommendations/{sample}_recommendations.txt"
#     conda:
#         "ont"
#     script:
#         "scripts/nutritional_recommendations.py"

# #######################################
# # Rule 11: Generate Final Report
# #######################################
# rule generate_report:
#     input:
#         kraken_report = "results/kraken/{sample}_kraken_report.txt",
#         bracken_output = "results/bracken/{sample}_bracken_output.txt",
#         humann_output = "results/humann/{sample}_pathways_abundance.tsv",
#         amr_output = "results/amr/{sample}_amr_output.tsv",
#         maaslin2_output = "results/maaslin2/{sample}_disease_association.tsv",
#         recommendations = "results/recommendations/{sample}_recommendations.txt"
#     output:
#         report = "results/reports/{sample}_microbiome_report.pdf"
#     conda:
#         "ont"
#     shell:
#         """
#         pandoc -s --toc \
#         --metadata title="Microbiome Report for {wildcards.sample}" \
#         --pdf-engine=xelatex \
#         -o {output.report} {input.kraken_report} {input.bracken_output} {input.humann_output} {input.amr_output} {input.maaslin2_output} {input.recommendations}
#         """

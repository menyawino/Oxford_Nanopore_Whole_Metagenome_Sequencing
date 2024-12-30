# #######################################
# # EXPERIMENTAL Rule: Compare Bracken Output to Phenotype Database
# #######################################
# rule compare_phenotypes:
#     input:
#         bracken_output = rules.reestimate_abundance.output.bracken_output,
#         phenotype_db = "workflow/config/phenotype_summary.tsv"
#     output:
#         phenotype_likelihood = "results/004_pathways/disease_phenotypes/{sample}_phenotype_likelihood.txt"
#     params:
#         script = "scripts/calculate_phenotype_likelihood.py"
#     threads:
#         config["threads"]
#     conda:
#         "humann_env"
#     benchmark:
#         "benchmark/004_pathways/disease_phenotypes/{sample}.time"
#     log:
#         "logs/004_pathways/disease_phenotypes/{sample}.log"
#     shell:
#         """
#         python {params.script} \
#         --bracken {input.bracken_output} \
#         --phenotypes {input.phenotype_db} \
#         --output {output.phenotype_likelihood} \
#         --threads {threads} \
#         &> {log}
#         """


# #######################################
# # Rule: Metabolite Prediction with MelonnPan
# #######################################
# rule melonnpan_prediction:
#     input:
#         pathways_abundance = rules.map_ko_to_metabolites.output.metabolites
#     output:
#         metabolites = "results/005_metabolites/melonnpan/MelonnPan_Predicted_Metabolites.txt",
#         rtsi = "results/005_metabolites/melonnpan/MelonnPan_RTSI.txt"
#     conda:
#         "melonpann_env"
#     threads:
#         config["threads"]
#     benchmark:
#         "benchmark/005_metabolites/melonnpan/melonnpan.time"
#     params:
#         predict_metabolites = config["predict_metabolites"]
#     log:
#         "logs/005_metabolites/melonnpan/melonnpan.log"
#     shell:
#         """
#         Rscript {params.predict_metabolites} \
#         -i {input.pathways_abundance} \
#         -o results/005_metabolites/melonnpan/ \
#         &> {log}
#         """


# #########################################
# # EXPERIMENTAL Rule: Calculate Taxa Contribution to Pathways
# #########################################
# rule calculate_taxa_contribution:
#     input:
#         pathways_abundance = rules.humann_functional_profiling.output.pathways_abundance,
#     output:
#         taxa_contribution = "results/004_pathways/humann/{sample}/{sample}_taxa_contribution.tsv"
#     params:
#         script = "scripts/calculate_taxa_contribution.py"
#     threads:
#         config["threads"]
#     conda:
#         "humann_env"
#     benchmark:
#         "benchmark/004_pathways/humann/{sample}_taxa_contribution.time"
#     log:
#         "logs/004_pathways/humann/{sample}_taxa_contribution.log"
#     shell:
#         """
#         python {params.script} \
#         --input {input.pathways_abundance} \
#         --output {output.taxa_contribution} \
#         &> {log}
#         """



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
#         &> {log}
#         """


# #######################################
# # Rule: MSA with Clustal Omega
# #######################################
# rule msa_clustalo:
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
#         # Run Clustal Omega for multiple sequence alignment
#         clustalo -i {input.contigs} \
#         -o {output.msa} \
#         --seqtype=DNA \
#         --infmt=fa \
#         --outfmt=fa \
#         --threads={threads} \
#         --force \
#         --verbose \
#         --iter=1 \
#         --log {log} \
#         &>> {log}
#         """

# #######################################
# # Rule: MSA with MUSCLE
# #######################################
# rule msa_muscle:
#     input:
#         contigs = rules.assemble_spades.output.contigs
#     output:
#         msa = "results/006_tree/msa/{sample}_msa.fasta"
#     conda:
#         "msa_tools"
#     threads: 
#         config["threads"]
#     benchmark:
#         "benchmark/006_tree/msa/{sample}.time"
#     log:
#         "logs/006_tree/msa/{sample}.log"
#     shell:
#         """
#         # Run MUSCLE for multiple sequence alignment
#         muscle -align {input.contigs} -output {output.msa} -maxiters 2 -diags1 -sv -distance1 kbit20_3 -threads {threads} &> {log}
#         """

# #######################################
# # Rule: Phylogenetic Tree Construction (FastTree)
# #######################################
# rule tree_fasttree:
#     input:
#         msa = rules.msa_clustalo.output.msa
#     output:
#         tree = "results/006_tree/tree/{sample}_tree.nwk"
#     conda:
#         "ont"
#     benchmark:
#         "benchmark/006_tree/tree/{sample}.time"
#     log:
#         "logs/006_tree/tree/{sample}.log"
#     shell:
#         """
#         fasttree {input.msa} > {output.tree} \
#         &> {log}
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
#         amrfinder -n {input.fastq} -o {output.amr_output} &> {log}
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
#         maaslin2 --input_data {input.taxonomy_profile} --input_metadata {input.metadata} --output results/maaslin2 &> {log}
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

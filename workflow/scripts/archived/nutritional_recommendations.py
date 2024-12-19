import pandas as pd

# Load the input data
taxonomy_file = snakemake.input.taxonomy_profile
pathway_file = snakemake.input.pathways_abundance

# Process the data to generate a health score (dummy example)
def calculate_health_score(taxonomy_file, pathway_file):
    # Read taxonomy data and functional data
    taxa_data = pd.read_csv(taxonomy_file, sep="\t")
    pathway_data = pd.read_csv(pathway_file, sep="\t")
    
    # Example calculation: give a higher score if SCFA pathways are abundant
    scfa_score = pathway_data[pathway_data['Pathway'].str.contains('SCFA')]['Abundance'].sum()
    
    # Create the health score (simplified)
    health_score = min(100, scfa_score * 10)
    
    return health_score

score = calculate_health_score(taxonomy_file, pathway_file)

# Save the health score to a file
with open(snakemake.output.health_score, "w") as f:
    f.write(f"Gut Health Score: {score}\n")

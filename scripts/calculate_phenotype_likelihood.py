import argparse
import pandas as pd
from fuzzywuzzy import process

def load_data(bracken_file, phenotype_file):
    bracken_df = pd.read_csv(bracken_file, sep='\t')
    phenotype_df = pd.read_csv(phenotype_file, sep='\t', dtype=str, comment='#', header=0, low_memory=False)
    print("Phenotype DataFrame columns:", phenotype_df.columns)  # Debugging line
    return bracken_df, phenotype_df

def normalize_abundance_mean(phenotype_df):
    phenotype_df['abudance mean'] = phenotype_df['abudance mean'].astype(float)
    max_abundance_mean = phenotype_df['abudance mean'].max()
    phenotype_df['normalized_abundance_mean'] = phenotype_df['abudance mean'] / max_abundance_mean
    return phenotype_df

def standardize_names(df, column):
    df[column] = df[column].str.lower().str.strip()
    return df

def fuzzy_match_species(species, phenotype_species_list):
    match, score = process.extractOne(species, phenotype_species_list)
    return match if score > 80 else None

def calculate_likelihood(bracken_df, phenotype_df):
    likelihoods = {}
    phenotype_species_list = phenotype_df['scientific name'].unique()
    
    for index, row in bracken_df.iterrows():
        species = row['name'].lower().strip()
        abundance = row['fraction_total_reads']
        matched_species = fuzzy_match_species(species, phenotype_species_list)
        
        if matched_species:
            phenotypes = phenotype_df[phenotype_df['scientific name'] == matched_species]
            for _, phenotype_row in phenotypes.iterrows():
                phenotype = phenotype_row['phenotype']
                phenotype_term = phenotype_row['phenotype term']
                likelihood = abundance * phenotype_row['normalized_abundance_mean']  # Using normalized 'abudance mean'
                if phenotype in likelihoods:
                    likelihoods[phenotype]['likelihood'] += likelihood
                else:
                    likelihoods[phenotype] = {'likelihood': likelihood, 'term': phenotype_term}
    return likelihoods

def save_likelihoods(likelihoods, output_file, high_likelihood_threshold):
    sorted_likelihoods = sorted(likelihoods.items(), key=lambda x: x[1]['likelihood'], reverse=True)
    with open(output_file, 'w') as f:
        f.write(f"# High likelihood threshold: {high_likelihood_threshold}\n")
        f.write("Phenotype\tLikelihood\tTerm\tHigh Likelihood\n")
        for phenotype, data in sorted_likelihoods:
            high_likelihood = data['likelihood'] > high_likelihood_threshold
            f.write(f"{phenotype}\t{data['likelihood']}\t{data['term']}\t{high_likelihood}\n")

def main():
    parser = argparse.ArgumentParser(description="Calculate phenotype likelihoods from Bracken output.")
    parser.add_argument('--bracken', required=True, help="Path to the Bracken output file.")
    parser.add_argument('--phenotypes', required=True, help="Path to the phenotype database file.")
    parser.add_argument('--output', required=True, help="Path to the output file.")
    args = parser.parse_args()

    bracken_df, phenotype_df = load_data(args.bracken, args.phenotypes)
    bracken_df = standardize_names(bracken_df, 'name')
    phenotype_df = standardize_names(phenotype_df, 'scientific name')
    phenotype_df = normalize_abundance_mean(phenotype_df)
    high_likelihood_threshold = phenotype_df['abudance mean'].quantile(0.90)  # 90th percentile
    likelihoods = calculate_likelihood(bracken_df, phenotype_df)
    save_likelihoods(likelihoods, args.output, high_likelihood_threshold)

if __name__ == "__main__":
    main()

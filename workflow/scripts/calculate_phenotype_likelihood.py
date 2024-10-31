import argparse
import pandas as pd

def load_data(bracken_file, phenotype_file):
    bracken_df = pd.read_csv(bracken_file, sep='\t')
    phenotype_df = pd.read_csv(phenotype_file, sep='\t')
    return bracken_df, phenotype_df

def calculate_likelihood(bracken_df, phenotype_df):
    likelihoods = {}
    for index, row in bracken_df.iterrows():
        species = row['name']
        abundance = row['fraction_total_reads']
        if species in phenotype_df['species'].values:
            phenotypes = phenotype_df[phenotype_df['species'] == species]
            for _, phenotype_row in phenotypes.iterrows():
                phenotype = phenotype_row['phenotype']
                likelihood = abundance * phenotype_row['likelihood_factor']
                if phenotype in likelihoods:
                    likelihoods[phenotype] += likelihood
                else:
                    likelihoods[phenotype] = likelihood
    return likelihoods

def save_likelihoods(likelihoods, output_file):
    with open(output_file, 'w') as f:
        for phenotype, likelihood in likelihoods.items():
            f.write(f"{phenotype}\t{likelihood}\n")

def main():
    parser = argparse.ArgumentParser(description="Calculate phenotype likelihoods from Bracken output.")
    parser.add_argument('--bracken', required=True, help="Path to the Bracken output file.")
    parser.add_argument('--phenotypes', required=True, help="Path to the phenotype database file.")
    parser.add_argument('--output', required=True, help="Path to the output file.")
    args = parser.parse_args()

    bracken_df, phenotype_df = load_data(args.bracken, args.phenotypes)
    likelihoods = calculate_likelihood(bracken_df, phenotype_df)
    save_likelihoods(likelihoods, args.output)

if __name__ == "__main__":
    main()

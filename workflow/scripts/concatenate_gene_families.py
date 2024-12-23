import pandas as pd
import argparse

def concatenate_gene_families(input_files, output_file):
    dataframes = []
    for file in input_files:
        sample_name = file.split('/')[-1].split('_')[0]
        df = pd.read_csv(file, sep='\t', index_col=0)
        df.columns = [sample_name]
        dataframes.append(df)
    
    concatenated_df = pd.concat(dataframes, axis=1)
    concatenated_df.to_csv(output_file, sep='\t')

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Concatenate gene families based on sample names.")
    parser.add_argument('--input', nargs='+', required=True, help="Input gene families files.")
    parser.add_argument('--output', required=True, help="Output concatenated gene families file.")
    args = parser.parse_args()
    
    concatenate_gene_families(args.input, args.output)

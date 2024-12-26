import pandas as pd
import argparse
import numpy as np
from concurrent.futures import ThreadPoolExecutor

def augment_data_with_variation(df, min_unique_values=4):
    new_rows = []
    for col in df.columns:
        unique_values = set(df[col].dropna().unique())
        na_indices = df[col].isna()
        if na_indices.any():
            new_values = []
            while len(new_values) < na_indices.sum():
                new_value = np.random.random()
                if new_value not in unique_values:
                    new_values.append(new_value)
                    unique_values.add(new_value)
            df.loc[na_indices, col] = new_values
        while len(unique_values) < min_unique_values:
            new_value = np.random.random()
            unique_values.add(new_value)
            new_row = pd.Series({col: new_value}, name=len(df) + len(new_rows))
            new_rows.append(new_row)
    if new_rows:
        new_rows_df = pd.DataFrame(new_rows)
        df = pd.concat([df, new_rows_df])
    return df

def read_and_process_file(file):
    sample_name = file.split('/')[-1].split('_')[0]
    df = pd.read_csv(file, sep='\t', index_col=0)
    df.columns = [sample_name]
    return df

def concatenate_gene_families(input_files, output_file, num_threads):
    with ThreadPoolExecutor(max_workers=num_threads) as executor:
        dataframes = list(executor.map(read_and_process_file, input_files))
    
    concatenated_df = pd.concat(dataframes, axis=1)
    concatenated_df = concatenated_df.transpose()  # Transpose the DataFrame to have sample names as the first column
    concatenated_df = augment_data_with_variation(concatenated_df)  # Augment data to ensure sufficient variation
    concatenated_df.to_csv(output_file, sep='\t')

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Concatenate gene families based on sample names.")
    parser.add_argument('--input', nargs='+', required=True, help="Input gene families files.")
    parser.add_argument('--output', required=True, help="Output concatenated gene families file.")
    parser.add_argument('--threads', type=int, default=1, help="Number of threads to use.")
    args = parser.parse_args()
    
    concatenate_gene_families(args.input, args.output, args.threads)

import pandas as pd
import argparse
import numpy as np
import requests
from concurrent.futures import ThreadPoolExecutor

def read_and_process_file(file):
    sample_name = file.split('/')[-1].split('_')[0]
    df = pd.read_csv(file, sep='\t', index_col=0, comment='#')
    df = df[~df.index.isin(['UNMAPPED', 'UNGROUPED'])]
    df = df[df.columns[df.sum() != 0]]
    df.columns = [sample_name]
    if df.index.duplicated().any():
        print("Duplicate indices detected. Making indices unique.")
        df.index = df.index + "_" + pd.Series(range(len(df))).astype(str)
    print(df)
    return df

def get_reactions_from_ko(ko_id):
    url = f"http://rest.kegg.jp/link/reaction/{ko_id}"
    response = requests.get(url)
    return response.text

def get_compounds_from_reaction(reaction_id):
    url = f"http://rest.kegg.jp/get/{reaction_id}"
    response = requests.get(url)
    return response.text

def process_ko_id(ko_id, df):
    metabolite_abundance = {}
    reaction_mapping = get_reactions_from_ko(f"ko:{ko_id}")
    for line in reaction_mapping.strip().split('\n'):
        if '\t' not in line:
            continue
        _, reaction_id = line.split('\t')
        reaction_details = get_compounds_from_reaction(reaction_id.split(':')[1])
        metabolites = []
        for line in reaction_details.strip().split('\n'):
            if line.startswith("DEFINITION"):
                definition = line.split('DEFINITION')[1].strip()
                metabolites = [s.strip() for s in definition.split('<=>')[0].split('+')] + [s.strip() for s in definition.split('<=>')[1].split('+')]
        for metabolite in metabolites:
            parts = [p for p in metabolite.split() if p]
            if parts and parts[0].isdigit():
                count = int(parts[0])
                metabolite_name = " ".join(parts[1:])
            else:
                count = 1
                metabolite_name = metabolite
            if metabolite_name not in metabolite_abundance:
                metabolite_abundance[metabolite_name] = 0
            metabolite_abundance[metabolite_name] += df.loc[ko_id].values[0] * count
    return metabolite_abundance

def map_ko_to_metabolites(df, num_threads):
    metabolite_abundance = {}
    with ThreadPoolExecutor(max_workers=num_threads) as executor:
        results = list(executor.map(lambda ko_id: process_ko_id(ko_id, df), df.index))
    for result in results:
        for metabolite, abundance in result.items():
            if metabolite not in metabolite_abundance:
                metabolite_abundance[metabolite] = 0
            metabolite_abundance[metabolite] += abundance
    return pd.DataFrame.from_dict(metabolite_abundance, orient='index', columns=['Abundance'])

def process_files(input_files, output_file, num_threads):
    with ThreadPoolExecutor(max_workers=num_threads) as executor:
        dataframes = list(executor.map(read_and_process_file, input_files))
    
    for df, file in zip(dataframes, input_files):
        sample_name = file.split('/')[-1].split('_')[0]
        metabolite_df = map_ko_to_metabolites(df, num_threads)
        metabolite_df.to_csv(f"{output_file}", sep='\t')

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Map KO to metabolites for each KEGG reactions file without concatenation.")
    parser.add_argument('--input', nargs='+', required=True, help="Input KEGG reactions files.")
    parser.add_argument('--output', required=True, help="Output metabolites file suffix.")
    parser.add_argument('--threads', type=int, default=1, help="Number of threads to use.")
    args = parser.parse_args()
    
    process_files(args.input, args.output, args.threads)

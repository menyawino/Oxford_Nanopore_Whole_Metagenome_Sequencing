import pandas as pd
import argparse
import requests
import time

def read_and_process_file(file):
    # turn list into a string
    file = file[0]
    print(f"Processing {file}")

    sample_name = file.split('/')[-1].split('_')[0]
    df = pd.read_csv(file, sep='\t')
    df = df[df.columns[df.sum() != 0]]
    df.columns = ["Reaction", "Abundance"]
    if df.index.duplicated().any():
        print("Duplicate indices detected. Making indices unique.")
        df.index = df.index + "_" + pd.Series(range(len(df))).astype(str)
        
    # remove UNMAPPED and UNGROUPED rows
    for i, row in df.iterrows():
        if row["Reaction"] == "UNMAPPED" or row["Reaction"] == "UNGROUPED":
            df.drop(i, inplace=True)

    # reset index
    df.reset_index(drop=True, inplace=True)
    

    return df.to_dict(orient='list')

def get_reactions_from_ko(ko_id):
    url = f"http://rest.kegg.jp/link/reaction/{ko_id}"
    response = requests.get(url)
    time.sleep(1)  # delay to avoid KEGG API block
    return response.text

def get_compounds_from_reaction(reaction_id):
    url = f"http://rest.kegg.jp/get/{reaction_id}"
    response = requests.get(url)
    time.sleep(1)  # delay to avoid KEGG API block
    return response.text

def process_ko_id(file, output_file):
    df = read_and_process_file(file)

    metabolite_abundance = {}

    for ko_id in df['Reaction']:
        print("Processing KO ID:", ko_id)
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
                metabolite_abundance[metabolite_name] += df['Abundance'][df['Reaction'].index(ko_id)] * count
        metabolite_df = pd.DataFrame.from_dict(metabolite_abundance, orient='index', columns=['Abundance'])
        metabolite_df.to_csv(f"{output_file}", sep='\t')
    return pd.DataFrame.from_dict(metabolite_abundance, orient='index', columns=['Abundance'])

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Map KO to metabolites for KEGG reactions abundance file.")
    parser.add_argument('--input', nargs='+', required=True, help="Input KEGG reactions file.")
    parser.add_argument('--output', required=True, help="Output metabolites file suffix.")
    parser.add_argument('--threads', type=int, default=1, help="Number of threads to use.")
    args = parser.parse_args()
    
    process_ko_id(args.input, args.output)

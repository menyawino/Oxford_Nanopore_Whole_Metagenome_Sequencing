import pandas as pd
import sys
import requests

def fetch_kegg_disease_associations():
    # Fetch KEGG pathway-disease associations
    url = "http://rest.kegg.jp/link/disease/pathway"
    response = requests.get(url)
    data = response.text.splitlines()
    
    # Parse the data into a dictionary
    disease_map = {}
    for line in data:
        pathway, disease = line.split('\t')
        pathway = pathway.split(':')[1]
        disease = disease.split(':')[1]
        if disease.startswith('H'):
            disease_map[pathway] = disease
    return disease_map

def main(humann_output, disease_association_output):
    # Load HUMAnN output
    df = pd.read_csv(humann_output, sep='\t')
    
    # Fetch disease associations
    disease_map = fetch_kegg_disease_associations()
    
    # Map pathways to diseases
    df['Disease'] = df['Pathway'].map(disease_map)
    
    # Filter out rows without disease associations
    df = df.dropna(subset=['Disease'])
    
    # Save the result
    df.to_csv(disease_association_output, sep='\t', index=False)

if __name__ == "__main__":
    humann_output = sys.argv[1]
    disease_association_output = sys.argv[2]
    main(humann_output, disease_association_output)

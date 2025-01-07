import pandas as pd
import requests
from collections import defaultdict

# Set your email for NCBI API access
NCBI_EMAIL = "your_email@example.com"

# NCBI Base URLs
NCBI_GENE_SEARCH = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi"
NCBI_GENE_SUMMARY = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi"

def fetch_gene_ids(taxid):
    """Fetch gene IDs for a given TaxID from NCBI Gene."""
    params = {
        "db": "gene",
        "term": f"txid{taxid}[Organism]",
        "retmax": 1000,
        "email": NCBI_EMAIL,
        "retmode": "json"
    }
    response = requests.get(NCBI_GENE_SEARCH, params=params)
    response.raise_for_status()
    data = response.json()
    return data.get('esearchresult', {}).get('idlist', [])

def fetch_gene_families(gene_ids):
    """Fetch gene family information for a list of Gene IDs."""
    gene_families = {}
    if not gene_ids:
        return gene_families
    
    # Split gene_ids into smaller batches
    batch_size = 200
    for i in range(0, len(gene_ids), batch_size):
        ids_batch = gene_ids[i:i + batch_size]
        ids = ",".join(ids_batch)
        params = {
            "db": "gene",
            "id": ids,
            "retmode": "json",
            "email": NCBI_EMAIL
        }
        response = requests.get(NCBI_GENE_SUMMARY, params=params)
        response.raise_for_status()
        data = response.json()
        
        for gene_id, details in data.get('result', {}).items():
            if gene_id == "uids":
                continue
            family = details.get('otheraliases', 'Unknown_Family')
            gene_families[gene_id] = family
    
    return gene_families

def map_taxa_to_gene_families_abundance(input_csv, output_csv):
    """Map TaxIDs to gene families, aggregate abundance, and save results."""
    # Read input CSV
    df = pd.read_csv(input_csv)
    
    # Initialize a defaultdict to store family abundances per sample
    sample_family_abundance = defaultdict(lambda: defaultdict(float))
    
    for index, row in df.iterrows():
        sample_name = row.iloc[0]
        for taxid, abundance in row.iloc[1:].items():
            if pd.isna(abundance) or abundance == 0:
                continue
            
            print(f"Processing TaxID {taxid} for sample {sample_name}...")
            try:
                gene_ids = fetch_gene_ids(taxid)
                gene_families = fetch_gene_families(gene_ids)
                
                for gene_id, family in gene_families.items():
                    sample_family_abundance[sample_name][family] += abundance
            
            except Exception as e:
                print(f"Failed for TaxID {taxid}: {e}")
    
    # Create output DataFrame
    output_data = []
    for sample, family_abundances in sample_family_abundance.items():
        row = {"Sample": sample}
        row.update(family_abundances)
        output_data.append(row)
    
    output_df = pd.DataFrame(output_data).fillna(0)
    output_df.to_csv(output_csv, index=False)
    print(f"Gene family abundance CSV saved to {output_csv}")

def run_test_subset(input_csv, test_output_csv):
    """Run the process on a subset of the input file for testing."""
    df = pd.read_csv(input_csv)
    subset_df = df.iloc[:2, :3]  # Select first 2 samples and first 2 taxids
    subset_df.to_csv("test_subset.csv", index=False)
    map_taxa_to_gene_families_abundance("test_subset.csv", test_output_csv)

# Run the test subset process
run_test_subset("abund.csv", "test_gene_family_abundance.csv")

# Run the actual process
map_taxa_to_gene_families_abundance("abund.csv", "gene_family_abundance.csv")
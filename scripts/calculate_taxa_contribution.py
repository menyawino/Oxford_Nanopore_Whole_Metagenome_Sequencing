
import csv
from collections import defaultdict

def calculate_taxa_contribution(input_file, output_file):
    pathway_abundance = {}
    taxa_contributions = defaultdict(list)

    with open(input_file, 'r') as infile:
        reader = csv.reader(infile, delimiter='\t')
        next(reader)  # Skip header
        for row in reader:
            pathway, abundance = row
            abundance = float(abundance)
            if '|' not in pathway:
                pathway_abundance[pathway] = abundance
            else:
                base_pathway = pathway.split('|')[0]
                taxa_contributions[base_pathway].append((pathway, abundance))

    with open(output_file, 'w', newline='') as outfile:
        writer = csv.writer(outfile, delimiter='\t')
        writer.writerow(['Pathway', 'Taxa', 'Abundance', 'Relative Contribution'])
        for pathway, taxa_list in taxa_contributions.items():
            total_abundance = pathway_abundance.get(pathway, 0)
            if total_abundance > 0:
                for taxa, abundance in sorted(taxa_list, key=lambda x: x[1], reverse=True):
                    relative_contribution = abundance / total_abundance
                    writer.writerow([pathway, taxa, abundance, relative_contribution])

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description='Calculate taxa contribution to pathways.')
    parser.add_argument('--input', required=True, help='Input TSV file with pathway abundances.')
    parser.add_argument('--output', required=True, help='Output TSV file with taxa contributions.')
    args = parser.parse_args()
    calculate_taxa_contribution(args.input, args.output)
#!/usr/bin/env python3

import argparse
import json
import sys
from anytree import Node, RenderTree

def parse_kraken_output(output):
    lines = output.strip().split('\n')
    root = Node("root")  # Create a root node for the tree
    current_nodes = {0: root}  # Keep track of nodes by their hierarchy level

    for line in lines:
        parts = line.split('\t')
        if len(parts) < 6:
            continue  # Skip invalid lines

        # Determine the number of leading spaces to find the hierarchy level
        leading_spaces = len(parts[5]) - len(parts[5].lstrip())
        level = leading_spaces // 2  # Assuming each indentation level is 2 spaces
        
        # Create a new node
        taxon = parts[5].strip()  # Taxon name
        new_node = Node(taxon, parent=current_nodes.get(level))  # Set the parent to the last node at this level

        # Update the current_nodes dictionary to include the new node
        current_nodes[level + 1] = new_node  # Add new node as a child for the next level

    return root

def print_tree(node, output_file):
    try:
        with open(output_file, 'w') as f:
            for pre, _, node in RenderTree(node):
                f.write(f"{pre}{node.name}\n")
    except IOError as e:
        print(f"Error writing to file {output_file}: {e}", file=sys.stderr)
        sys.exit(1)

def tree_to_json(node):
    return {
        "name": node.name,
        "children": [tree_to_json(child) for child in node.children]
    }

def main():
    parser = argparse.ArgumentParser(
        description="Parse Kraken2 output and render a phylogenetic tree.",
        epilog="Example usage: python tree.py -in kraken_output.txt -out tree_output.txt --json-out tree_output.json"
    )
    parser.add_argument(
        '-in', '--input', required=True, help="Path to the Kraken2 output file."
    )
    parser.add_argument(
        '-out', '--output', required=True, help="Path to the output text file for tree structure."
    )
    parser.add_argument(
        '--json-out', help="Path to optional JSON output file (optional)."
    )

    args = parser.parse_args()

    # Read Kraken2 output file with error handling
    try:
        with open(args.input, 'r') as infile:
            kraken2_output = infile.read()
    except FileNotFoundError:
        print(f"Error: Input file {args.input} not found.", file=sys.stderr)
        sys.exit(1)
    except IOError as e:
        print(f"Error reading input file {args.input}: {e}", file=sys.stderr)
        sys.exit(1)

    # Parse the Kraken2 output and create the tree
    try:
        phylogenetic_tree = parse_kraken_output(kraken2_output)
    except Exception as e:
        print(f"Error parsing Kraken2 output: {e}", file=sys.stderr)
        sys.exit(1)

    # Print the tree structure to a text file
    print_tree(phylogenetic_tree, args.output)

    # Optionally, output to JSON format if the --json-out flag is provided
    if args.json_out:
        try:
            with open(args.json_out, 'w') as json_file:
                json.dump(tree_to_json(phylogenetic_tree), json_file, indent=2)
        except IOError as e:
            print(f"Error writing JSON output file {args.json_out}: {e}", file=sys.stderr)
            sys.exit(1)

    print("Tree parsing and output generation complete.")

if __name__ == "__main__":
    main()

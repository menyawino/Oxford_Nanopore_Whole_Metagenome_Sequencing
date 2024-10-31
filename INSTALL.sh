#!/bin/bash


# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if Miniconda is installed
if ! command_exists conda; then
    echo "Miniconda not found. Installing Miniconda..."
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O Miniconda3-latest-Linux-x86_64.sh
    bash Miniconda3-latest-Linux-x86_64.sh -b -p $HOME/miniconda
    export PATH="$HOME/miniconda/bin:$PATH"
    source $HOME/miniconda/bin/activate
else
    echo "Miniconda is already installed."
fi

# Initialize conda
conda init

echo "Please close your terminal, open a new one, and rerun this script to complete the installation."

# Add necessary channels
conda config --add channels conda-forge
conda config --add channels bioconda
conda config --add channels r

# Create environment with Snakemake installed
conda create -y -n metagenomic_pipeline snakemake

echo "Installation complete. To activate the environment, run 'conda activate metagenomic_pipeline'."

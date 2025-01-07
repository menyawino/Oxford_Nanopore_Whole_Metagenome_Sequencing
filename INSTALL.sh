#!/usr/bin/env bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if a conda environment exists
env_exists() {
    conda env list | grep -q "$1"
}

# Function to check if a conda channel is added
channel_exists() {
    conda config --show channels | grep -q "$1"
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
eval "$(conda shell.bash hook)"

# Add necessary channels if not already added
if ! channel_exists defaults; then
    conda config --add channels defaults
fi
if ! channel_exists conda-forge; then
    conda config --add channels conda-forge
fi
if ! channel_exists bioconda; then
    conda config --add channels bioconda
fi
if ! channel_exists r; then
    conda config --add channels r
fi
if ! channel_exists biobakery; then
    conda config --add channels biobakery
fi

# Install mamba if not already installed
if ! command_exists mamba; then
    conda install -y mamba -n base -c conda-forge
fi

# Set MAMBA_ROOT_PREFIX to avoid warnings
export MAMBA_ROOT_PREFIX="$HOME/miniconda"

# Check if the environment already exists
if env_exists metagenomics_pipeline; then
    echo "Environment 'metagenomics_pipeline' already exists."
else
    # Create environment with Snakemake installed using mamba
    mamba create -y -n metagenomics_pipeline snakemake
fi

# Clean up Miniconda installer if it exists
if [ -f Miniconda3-latest-Linux-x86_64.sh ]; then
    rm Miniconda3-latest-Linux-x86_64.sh
fi

# Initialize mamba shell
eval "$(mamba shell hook --shell bash)"

# Prompt to activate the environment
read -p "Do you want to activate the environment now? (y/n): " choice
if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
    mamba activate metagenomics_pipeline
fi

echo "Installation complete. To activate the environment, rerun the terminal then run 'mamba activate metagenomics_pipeline'."

# Instructions for zsh users
echo "If you are using zsh, please follow these steps:"
echo "- Run the following command to initialize mamba:"
echo '  eval "$(mamba shell hook --shell zsh)"'
echo "- Then activate the environment with:"
echo '  mamba activate metagenomics_pipeline'

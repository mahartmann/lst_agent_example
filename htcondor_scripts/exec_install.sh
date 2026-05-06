#!/bin/bash

export CONDA_DIR=/scratch/hartmann/miniconda3 #location of the miniconda installation

# Create a new conda environment an install requirements
source $CONDA_DIR/etc/profile.d/conda.sh
echo "Current conda environment: $CONDA_DEFAULT_ENV"

conda create --name lst_agent_example python=3.12
conda activate lst_agent_example
pip install -r requirements.txt

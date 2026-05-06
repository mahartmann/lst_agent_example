#!/bin/bash

# Create a new conda environment an install requirements
source /scratch/hartmann/miniconda3/etc/profile.d/conda.sh
echo "Current conda environment: $CONDA_DEFAULT_ENV"

conda create --name lst_agent_example python=3.12
conda activate lst_agent_example
pip install -r requirements.txt

#!/bin/bash

set -e  # Exit immediately if a command fails
set -o pipefail

# Create and activate conda env
echo "Creating Conda environment: ouroboros_env"
conda create -n ouroboros_env python=3.6 -y
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate ouroboros_env

# Install conda dependencies
echo "Installing core dependencies via conda..."
mamba install -y \
  "numpy>=1.16.4" "scipy>=1.3.0" "pandas>=0.21.0" \
  "anndata=0.7.5" "matplotlib>=3.1.0" "seaborn>=0.11.2" \
  "plotly>=5.24.1" "scikit-learn>=0.24.2" "cartopy"

# Install pip-only packages
echo "Installing TensorFlow and TFP via pip..."
pip install tensorflow==1.14
pip install -U tensorflow-probability==0.7.0

# Install scPhere
echo "Cloning and installing scPhere..."
cd /projects/steiflab/research/hmacdonald/applications/
git clone https://github.com/klarman-cell-observatory/scPhere || true
cd scPhere
python setup.py install
cd ../

# Clone and install Ouroboros
echo "Cloning and installing Ouroboros..."
cd /projects/steiflab/research/hmacdonald/applications/
git clone https://github.com/haleymac/Ouroboros.git || true
cd Ouroboros
pip install .

pip install --upgrade nbformat

# necessary for subsequent plotting only, not running Ouroboros main
pip install -U kaleido

echo "✅ Environment setup complete. Activate it with:"
echo "   conda activate ouroboros_env"

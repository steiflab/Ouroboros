import os
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'

import warnings
warnings.filterwarnings("ignore", category=FutureWarning)
warnings.filterwarnings("ignore", category=DeprecationWarning)

from .main import run_ouroboros
from .ouroboros_functions import (
    plot_sphere,
    check_genes,
    read_in_features,
    read_in_refembed,
    plot_gene_sphere,
    find_cycle_pole,
    sphere_snapshot,
    rotate_north
)

__version__ = "0.1.0"

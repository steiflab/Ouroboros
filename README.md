<p align="center" style="margin-bottom: 0;">
  <img src="docs/media/spinner.gif" alt="Ouroboros" width="120">
</p>
<h1 align="center" style="margin-top: 0;">Ouroboros</h1>

Ouroboros is designed to find cell cycle phase, cell cycle pseudotime and dormancy depth in scRNAseq datasets. It uses transfer learning within the latent space of a variational autoencoder to infer these features on new datasets. 

For more information see the Wiki: [wiki](https://steiflab.github.io/Ouroboros/)

## Installation 

Ouroboros supports Python **3.9–3.10**. Cartopy is an optional dependency required for some plotting functions. It is recommended to install via conda before installing Ouroboros. 

Installation: 
```
conda create -n ouroboros_env -c conda-forge python=3.9 pip=24.3.1
conda activate ouroboros_env 
conda install -c conda-forge cartopy 
pip install sc-ouroboros --no-cache-dir
```

Install directly from GitHub with:
```bash 
pip install git+https://github.com/steiflab/Ouroboros.git
```

[ScPhere](https://github.com/klarman-cell-observatory/scPhere) is included as part of Ouroboros and has been updated for compatibility with TensorFlow 2. ScPhere was originally developed by Jiarui Ding and colleagues at the Klarman Cell Observatory.

## Running Ouroboros 
For a full tutorial see the Wiki: [wiki](https://steiflab.github.io/Ouroboros/)

There are seperate tutorials for python (scanpy) and R (seurat) users, and an additonal tutorial to embed RNA velocity vectors into the sphere. 



### To run Ouroboros on an h5ad/ Scanpy object

It's important to note that Ouroboros only works on **raw** counts, so make sure your raw counts are saved under adata.layers['raw_counts'] where Ouroboros can find them, and then save your scanpy object as an h5ad:

```python 
anndata.write_h5ad(adata.h5ad)
```

Then you can run Ouroboros on the command line like so: 
```bash 
ouroboros \
    --data /path/to/h5ad  \
    --data_type h5ad \
    --species human \
    --outdir /path/to/output/directory \
    --seed 0 \
    --repeat 5 
```

Arguments: 
| Argument      | Description                                                                   |
| ------------- | ----------------------------------------------------------------------------- |
| `--data`      | **Required.** Path to your input data file. Must be a `.h5ad` or `.csv` file. |
| `--data_type` | **Required.** Format of the input data. Must be `h5ad` or `csv`.              |
| `--species`   | Species of origin for the dataset. Must be `human` or `mouse`.  Default is human |
| `--outdir`    | Output directory where results (embeddings, figures, logs) will be saved. Default is '.'|
| `--seed`      | Seed used for Ouroborous for data reproducibility. Default is 0 |
| `--repeat`*    | Number of times to retrain model (only if input data is missing any training genes). Default is 1.|

\* If any gene is missing from training feature set from the input data, the model must be retrained. To ensure robust performance, Ouroboros will retrain the VAE {repeat} times and select the model that correlates with the consensus. However, increasing the repeat parameter will significantly extend runtime.





## Plotting Ouroboros output

We have included several python functions to help you explore the Ouroboros output sphere. 

See Wiki tutorials for more information


## Acknowledgements
This project makes use of scPhere, developed by the Broad Institute and distributed under the BSD 3-Clause License.

We have included a lightly modified version of scPhere (updated for TensorFlow 2.x support) within this repository.

If you use functionality derived from scPhere, please also cite:
Ding, J., Regev, A. Deep generative model embedding of single-cell RNA-Seq profiles on hyperspheres and hyperbolic spaces. Nat Commun 12, 2554 (2021). https://doi.org/10.1038/s41467-021-22851-4

## License
Ouroboros is distributed under the MIT License (see LICENSE).
scPhere is distributed under the BSD 3-Clause License (see scphere/LICENSE).

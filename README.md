# Ouroboros

<img src="docs/media/sphere_snake.png" alt="Ouroboros" width="200">

Ouroboros is designed to find cell cycle phase, cell cycle pseudotime and dormancy depth in scRNAseq datasets. It uses transfer learning within the latent space of a variational autoencoder to infer these features on new datasets. 

For more information see the Wiki: *add wiki*

## Installation 

**Dependencies:**
- python=3.6
- numpy>=1.16.4
- scipy>=1.3.0
- pandas>=0.21.0
- anndata=0.7.5
- matplotlib>=3.1.0
- seaborn>=0.11.2
- plotly>=5.24.1
- tensorflow=1.14
- tensorflow-probability=0.7.0
- scPhere
- scikit-learn>=0.24.2


To install manually follow these commands: 
*Note I prefer mamba to conda because it's far faster, but you can just replace any instance of 'mamba' with 'conda' if you wish*
```bash 
conda create -n ouroboros_env python=3.6
conda activate ouroboros_env

mamba install "numpy>=1.16.4" "scipy>=1.3.0" "pandas>=0.21.0" "anndata=0.7.5" "matplotlib>=3.1.0" "seaborn>=0.11.2" "plotly>=5.24.1" "scikit-learn>=0.24.2" "scanpy" "cartopy"

pip install tensorflow==1.14
pip install -U tensorflow-probability==0.7.0

pip install "setuptools_scm<6.4"

git clone https://github.com/klarman-cell-observatory/scPhere
cd scPhere
python setup.py install


git clone https://github.com/haleymac/Ouroboros.git
cd Ouroboros/
pip install .
```

These commands have been included in install.sh as well, so to avoid calling them manually just run: 
```bash
# Grab the installation script
wget https://raw.githubusercontent.com/haleymac/Ouroboros/main/install.sh
# execute it
bash install.sh
```
This will only work if you already have conda and mamba installed. Also note that 2 github repos (scPhere and Ouroboros) will be dumped in the working directory. 



## Running Ouroboros 
For a full tutorial see the Wiki: *add wiki*

Ouroboros is a command line tool designed to take either a saved .h5ad object or if you are an R user a saved csv with a cell/gene count matrix. 


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
    --outdir /path/to/output/directory
```

Arguments: 
| Argument      | Description                                                                   |
| ------------- | ----------------------------------------------------------------------------- |
| `--data`      | **Required.** Path to your input data file. Must be a `.h5ad` or `.csv` file. |
| `--data_type` | **Required.** Format of the input data. Must be `h5ad` or `csv`.              |
| `--species`   | Species of origin for the dataset. Must be `human` or `mouse`.  Default is human |
| `--outdir`    | Output directory where results (embeddings, figures, logs) will be saved. Default is '.'|






### To run Ouroboros on an R/Seurat object
Apologies, I'm mostly a python user so Ouroboros is largely tailered to those who use scanpy and h5ad objects. Given this, running Ouroboros for an R user requires a little bit of fussing, but is possible! Here are the instructions for doing so:

It's important to note that Ouroboros only works on **raw** counts. If you are using R (and therefore probably Seurat?) you will need to save your counts as a csv, with genes as your column names and cell ids under the columns 'cell_id' like so: 

** MAKE SURE YOU SAVE YOUR RAW COUNTS, NOT YOUR NORMALIZED COUNTS!!!!**
```
# Extract RAW counts matrix from Seurat object
counts <- GetAssayData(seurat_obj, slot = "counts")

# Transpose and convert to data frame
df <- as.data.frame(Matrix::t(counts))

# Add cell IDs as a column named "cell_id"
df$cell_id <- rownames(df)

# Move 'cell_id' to the first column
df <- df[, c("cell_id", setdiff(names(df), "cell_id"))]

# Write to CSV
write.csv(df, file = "test_df.csv", row.names = FALSE)
```

Once your h5ad or csv is saved, you can call Ouroboros on the command line:






## Plotting Ouroboros output

We have included several python functions to help you explore the Ouroboros output sphere. 

See Wiki tutorials for more information [*add link*]



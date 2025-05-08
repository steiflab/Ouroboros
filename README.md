# Ouroboros

Ouroboros is designed to find cell cycle phase, cell cycle pseudotime and dormancy depth in scRNAseq datasets. It uses transfer learning within the latent space of a variational autoencoder to infer these features on new datasets. 

VAE latent space: 

*add spinning png*


## Installation 

Ouroboros is a specific implementation of scPhere: [https://github.com/klarman-cell-observatory/scPhere]. Therefore the first thing to do is to download scPhere and get it all set up and working:


#### Option 1: yaml build
If you are running on linux you can likely just use my environment yaml to build your own environment:



#### Option 2: manual installation 
**Step 1: Make a conda env:**
```bash 
conda create -n ouroboros_env python=3.6

conda activate ouroboros_env
```

**Step 2: install dependencies**
**Dependencies:**
With conda (or better yet mamba)

numpy >= 1.16.4
scipy >= 1.3.0
pandas >= 0.21.0
anndata = 0.7.5
matplotlib >= 3.1.0
seaborn >= 0.11.2
plotly >= 5.24.1

Install with conda: 
```bash
conda install numpy=1.16.4 scipy=1.3.0 pandas=0.21.0 anndata=0.7.5 matplotlib=3.1.0 seaborn=0.11.2 plotly=5.24.1
```

Tensorflow v1.14.0 
tensorflow-probability v0.7.0 
We can use pip (in terminal) to install these packages, e.g.,
```bash
pip install tensorflow==1.14
pip install -U tensorflow-probability==0.7.0
```

If you want to make fancy flattened Robinson projections you should also include cartopy, though it isn't necessary to just run Ouroboros on the command line:
```bash
conda install cartopy=0.19.0.post1
```

#### Velocity environment 
Unfourtunately scvelo is very fussy with what packages it will play nice with, so  I ended up making a seperate environment to plot it's velocity vectors on my sphere:

the yaml for this env is called 'velocity_environment.yaml'
To build an env from it: 

*finish this*

## Running Ouroboros 

Ouroboros is a command line tool designed to take either a saved .h5ad object or if you are an R user a saved csv with a cell/gene count matrix. 

### To run Ouroboros on an h5ad
Yay this is originally how I wrote Ouroboros so it should be smooth. 

It's important to note that Ouroboros only works on **raw** counts, so make sure your raw counts are saved under adata.layers['raw_counts'] where Ouroboros can find them, and then save your scanpy object as an h5ad:

```python 
anndata.write_h5ad(adata.h5ad)
```

Then you can run Ouroboros on the command line like so: 
```bash 

```




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


## Performance
Our training dataset includes 5698 cells and 226 genes. When training (or retraining with missing genes):

- Training time: ~2 minutes (CPU)
- Memory usage: ~821.64 MB RAM
- Hardware used: 
    - **CPU**: Intel(R) Xeon(R) E7-8867 v4 @ 2.40GHz
    - **RAM**: 1.5 TB

The model is always retrained on the same number of cells, but will likely run faster if fewer features genes are included. Note this will likely make the model less accurate however. 




## Plotting Ouroboros output

We have included several python functions to help you explore the Ouroboros output sphere. 

plot_sphere(z_df, colour_by = 'KNN_phase', palette = None, ref = None, velocity = None, marker_size = 2, cycle_pole = reference_CC_pole_point, savefig = None, show = False)



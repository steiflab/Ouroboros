# CLI Usage 


### A note on feature genes

A specific feature set was used to originally train Ouroboros and create the VAE latent space. If your count matrix is missing any of these genes (maybe you used a different reference or filtered them out) Ouroboros will take the features that do exist in your count matrix and **retrain** the VAE, resulting in a slightly different latent space. This could result in lower accuracy than if the full feature set is used. 

I made functions (R and Python) to test if you're missing any genes before deploying Ouroboros - see wiki tutorials [add links] for more information. 

Note also that feature genes are named by their HUGO gene names( ex. CCNE1, CCNE2), and not by their ensembl IDs (ENS...) so ensure your adata.var_names or R gene names are in this format before running Ouroboros. 



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
Apologies, I'm mostly a python user so Ouroboros is largely tailored to those who use scanpy and h5ad objects. Given this, running Ouroboros for an R user requires a little bit of fussing, but is possible! Here are the instructions for doing so:

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


```bash 
ouroboros \
    --data /path/to/csv  \
    --data_type csv \
    --species human \
    --outdir /path/to/output/directory
```



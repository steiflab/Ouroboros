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
Ouroboros was written in python, so is tailored to those who use scanpy and h5ad objects. To run Ouroboros on Seurat objects you will have to export your raw counts and run the command line implementation of Ouroboros. See our Seurat (R) tutorial for more information. 

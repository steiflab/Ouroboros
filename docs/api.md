# API Reference

This page documents the main functions available when importing `ouroboros` as a Python package.

---

## `run_ouroboros(data, data_type, species='human', outdir='.')`

**Description:**  
Runs the full Ouroboros pipeline on either `.h5ad` or `.csv` input and outputs latent embeddings, pseudotime values, and plots.

**Parameters:**

| Name        | Type     | Description                                                             |
|-------------|----------|-------------------------------------------------------------------------|
| `data`      | `str` or `AnnData` | Path to file or pre-loaded AnnData object                      |
| `data_type` | `str`    | Either `'h5ad'` or `'csv'`                                              |
| `species`   | `str`    | `'human'` or `'mouse'` (mouse gene names are auto-mapped)              |
| `outdir`    | `str`    | Directory to write output CSVs and HTML plots                          |

**Returns:**  
`pandas.DataFrame` — DataFrame containing 3D coordinates and predicted states for each cell.

---
## `check_genes(adata)`

**Description:** Checks if any feature genes are missing from a test anndata object. Returns a list of missing genes 

**Parameters:**

| Parameter     | Type            | Description                                                                                                                                                         |
| ------------- | --------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `adata`        | `AnnData`     | Test anndata object with adata.var_names in HUGO formatting (e.x. `CCNE1`)                      |

---

## `read_in_features()`

**Description:** Reads in all Ouroboros feature genes. No input necessary. Returns a list of genes.  

---

## `read_in_refembed()`

**Description:** Reads in the reference dataset VAE latent space embedding dataframe. Only meaningful if VAE has not been retrained. Returns a pandas dataframe.  

---

## `find_cycle_pole(z_df, ref_embed)`

**Description:** If you retrained the VAE because you had missing genes, your cycle_pole will be in a different spot - run find_cycle_pole() to find it's new coordinates. 

**Example usage:**
```python
find_cycle_pole(    
    z_df: pd.DataFrame,
    ref_embed: pd.DataFrame = None,
)
```

**Parameters:**
| Parameter     | Type            | Description                                                                                                                                                         |
| ------------- | --------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `z_df`        | `DataFrame`     | The test cell dataframe with 3D spherical coordinates (`dim1`, `dim2`, `dim3`) and metadata columns such as phase labels or pseudotime.                             |
| `ref_embed`         | `DataFrame`     | Reference dataset embeddings, with columns `dim1`, `dim2`, `dim3`, and `phase`.                                                                            |



---

## `plot_sphere(z_df, colour_by = 'KNN_phase', palette = None, ref = None, velocity = None, marker_size = 2, cycle_pole = [0.86202236, 0.24824865, 0.44191636], savefig = None, show = False)`

**Description:**  
Generates an interactive 3D spherical projection of the Ouroboros latent space.

**Example usage**
```python
plot_sphere(
    z_df: pd.DataFrame,
    colour_by: str = 'KNN_phase',
    palette: dict | str = None,
    ref: pd.DataFrame = None,
    velocity: pd.DataFrame = None,
    marker_size: int = 2,
    cycle_pole: list[float] = reference_CC_pole_point,
    savefig: str = None,
    show: bool = False
)
```

**Parameters:**

| Parameter     | Type            | Description                                                                                                                                                         |
| ------------- | --------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `z_df`        | `DataFrame`     | The main cell dataframe with 3D spherical coordinates (`dim1`, `dim2`, `dim3`) and metadata columns such as phase labels or pseudotime.                             |
| `colour_by`   | `str`           | Column in `z_df` to color points by (e.g. `'KNN_phase'`, `'cell_cycle_pseudotime'`, `'dormancy_depth'`).                                                            |
| `palette`     | `dict` or `str` | Optional color map: dictionary for categorical data (e.g {`'G1'`: `'blue'`, `'G2M'`: `'green'`}), or colormap name (e.g. `'mako'`, `'rocket_r'`) for continuous data. If `None`, an appropriate default is used. |
| `ref`         | `DataFrame`     | Optional reference dataset to overlay, with columns `dim1`, `dim2`, `dim3`, and `phase`.                                                                            |
| `velocity`    | `DataFrame`     | Optional velocity vectors with columns `dim1`, `dim2`, `dim3`.                                                                                                      |
| `marker_size` | `int`           | Size of scatter points.                                                                                                                                             |
| `cycle_pole`  | `list[float]`   | A 3D point marking the known cell cycle pole for axis. If you did not retrain model, the reference is correct and you do not need to supply it. If you did retrain the model, you can either provide 'None' and not plot it, or use find_cycle_pole to identify it                                                                                                  |
| `savefig`     | `str`           | If provided, saves the plot as an HTML file to this path.                                                                                                           |
| `show`        | `bool`          | Whether to display the figure in a browser (via `plotly`).                                                                                                          |

---
## `def plot_gene_sphere(z_df, adata, gene_name, layer=None, ref=None, velocity=None, show=False, outpath=None, cycle_pole=reference_CC_pole_point)`

**Description:**  
Generates an interactive 3D spherical projection of the Ouroboros latent space, coloured by the expression of a given gene.

**Example usage**
```python
plot_gene_sphere(
    z_df: pd.DataFrame,
    adata: anndata.AnnData,
    gene_name: str,
    layer: str = None,
    ref: pd.DataFrame = None,
    ref_color: str = 'putative_phase_transition',
    ref_pal: dict = phase_pal_transition,
    velocity: pd.DataFrame = None,
    show: bool = False,
    outpath: str = None,
    cycle_pole: list[float] = reference_CC_pole_point
)
```

**Parameters:**


| Parameter    | Type                    | Description                                                                                   |
| ------------ | ----------------------- | --------------------------------------------------------------------------------------------- |
| `z_df`       | `DataFrame`             | DataFrame containing embedded cell coordinates (`dim1`, `dim2`, `dim3`) and metadata columns. |
| `adata`      | `AnnData`               | The original single-cell data object containing expression values.                            |
| `gene_name`  | `str`                   | Gene to plot. Must exist in `adata.var_names`.                                                |
| `layer`      | `str`, optional         | Name of the `.layers` slot in `adata` to use (e.g. `"log_counts"`). Defaults to `.X`.         |
| `ref`        | `DataFrame`, optional   | Optional reference cells with `dim1`, `dim2`, `dim3`, and metadata like phase.                |
| `velocity`   | `DataFrame`, optional   | Optional velocity vectors (same shape as `z_df`) with `dim1`, `dim2`, `dim3`.  See plot_velocity for more information.               |
| `show`       | `bool`, default `False` | Whether to display the plot interactively in a Jupyter notebook.                                                    |
| `outpath`    | `str`, optional         | If provided, saves the interactive Plotly figure as HTML.                                     |
| `cycle_pole` | `list[float]`           |  A 3D point marking the known cell cycle pole for axis. If you did not retrain model, the reference is correct and you do not need to supply it. If you did retrain the model, you can either provide 'None' and not plot it, or use find_cycle_pole to identify                                    |

---
## `rotate_north(z_df, reference_CC_pole_point = [0.86202236, 0.24824865, 0.44191636])`

**Description:** Rotate all points in the sphere such that the north point of the cycle pole becomes true north at [0,0,1]

**Example usage:**
```python
rotate_north(
    z_df: pd.DataFrame,
    reference_CC_pole_point: list[float] = [0.86202236, 0.24824865, 0.44191636]
) 
```

**Parameters::**

| Parameter                 | Type                    | Description                                                                                        |
| ------------------------- | ----------------------- | -------------------------------------------------------------------------------------------------- |
| `z_df`                    | `DataFrame`             | Input dataframe containing spherical coordinates (`dim1`, `dim2`, `dim3`) for each cell.           |
| `reference_CC_pole_point` | `list[float]`, optional | 3D vector indicating the "pole" direction to rotate. Default is the original Ouroboros cycle pole. |


This function returns: 

| Type        | Description                                                                                         |
| ----------- | --------------------------------------------------------------------------------------------------- |
| `DataFrame` | A copy of `z_df` with rotated `dim1`, `dim2`, `dim3` values so that the pole points to `[0, 0, 0]`. |

---

## `sphere_snapshot(lat, lon,  z_df, colour_by='KNN_phase', palette=None, radius = 1.2, ref_embed = None, vel_df = None, save_as_png=True, cycle_pole = [0, 0, 1])`


**Description:** Produces a png of the sphere at a given latitude and longtiude and writes it to a given output path. 

**Example usage:**
```python
sphere_snapshot(
    lat: int,
    long: int, 
    z_df: pd.DataFrame,
    colour_by: str, 
    radius: float, 
    gene_name: str,
    layer: str = None,
    ref_embed: pd.DataFrame = None,
    vel_df: pd.DataFrame = None,
    save_as_png: str # ex. /path/to/output/png
    cycle_pole: list[float] = [0,0,1]
)
```

**Parameters:**
| Parameter     | Type                      | Description                                                                                                                               |
| ------------- | ------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| `lat`         | `int`                     | Latitude angle (in degrees) to position the camera viewpoint. Must be in `[-90, 90]`.                                                     |
| `lon`         | `int`                     | Longitude angle (in degrees) to position the camera viewpoint. Must be in `[0, 360]`.                                                     |
| `z_df`        | `DataFrame`               | DataFrame containing spherical embedding coordinates (`dim1`, `dim2`, `dim3`) and metadata.                                               |
| `colour_by`   | `str`                     | Column in `z_df` to color points by (e.g., `'KNN_phase'`, `'cell_cycle_pseudotime'`).                                                     |
| `radius`      | `float`, optional         | Distance from the sphere center to the virtual camera. Controls zoom level.                                                               |
| `palette`     | `dict` or `str`, optional | Color palette. Use a dictionary for categorical values or a colormap name (e.g., `'mako'`) for continuous values.                         |
| `ref_embed`   | `DataFrame`, optional     | Optional reference dataset with `dim1`, `dim2`, `dim3`, and metadata columns (e.g., `phase`). Used for transparent background points.     |
| `vel_df`      | `DataFrame`, optional     | Optional velocity vectors with columns `dim1`, `dim2`, `dim3`. Drawn as arrows and cones.                                                 |
| `save_as_png` | `str`, optional           | Path to save the image as a PNG. If `None`, the image is not saved.                                                                       |
| `showlegend`  | `bool`, default `False`   | Whether to display the legend in the plot.                                                                                                |
| `cycle_pole`  | `list[float]`, optional   | 3D vector indicating the cell cycle pole. Defaults to `[0, 0, 1]`. If you haven't rotated the sphere the cycle pole will be off. |



---

## `convert_to_human_genes(data)`

**Description:**  
Converts mouse gene symbols in `Anndata` or `pandas df` input to human orthologs (HUGO format). Used internally in Ouroboros but included here in case you need it for other applications. Returns either an h5ad or df depending on input. 

---

## `plot_robinson_projection(z_df, colour_by, velocity_df=None, palette=None, ref_df=None, central_longitude=80, title="", alpha=0.7, scale=10, save_fig=None, rasterize=True, show=True)`

**Description:**
Projects 3D spherical coordinates onto a 2D Robinson map with flexible coloring by categorical or continuous metadata. Cartesian coordinates (`dim1`, `dim2`, `dim3`) are converted to longitude/latitude and drawn on a Robinson projection; coloring is auto-detected as continuous or categorical, NA values are shown in grey, and an optional reference set can be drawn as faint background points. Used for interpreting global cell state structure or transitions in a biologically interpretable planar projection. 

**Example usage:**
```python
plot_robinson_projection(
    z_df=embedding_df,
    colour_by='cell_cycle_pseudotime',
    velocity_df=velocity_df,
    palette='rocket_r',
    ref_df=reference_df,
    title="Differentiation Trajectory",
    scale=15,
    save_fig="robinson.png"
)
```

**Parameters:**
| Parameter           | Type                      | Description                                                                                                                                             |
| ------------------- | ------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| `z_df`              | `DataFrame`               | DataFrame containing 3D spherical embedding coordinates (`dim1`, `dim2`, `dim3`) and associated metadata for coloring.                                  |
| `colour_by`         | `str`                     | Column in `z_df` to color by. Automatically handled as categorical (e.g., `'KNN_phase'`) or continuous (e.g., `'cell_cycle_pseudotime'`).              |
| `velocity_df`       | `DataFrame`, optional     | Optional RNA velocity DataFrame with `dim1`, `dim2` columns representing directional flow vectors, drawn as quiver arrows.                              |
| `palette`           | `dict` or `str`, optional | Custom palette: a dict mapping labels to colors for categorical data, or a colormap name (e.g., `'mako'`, `'viridis'`) for continuous data. If `None`, a colormap is auto-selected (`rocket_r` for `cell_cycle_pseudotime`, `mako` for `dormancy_pseudotime`, else `viridis`; `tab20`/`phase_pal_transition` for categorical). |
| `ref_df`            | `DataFrame`, optional     | Optional reference DataFrame with `dim1`, `dim2`, `dim3` and a `phase` column. Plotted as faint background points colored by phase.                    |
| `central_longitude` | `int`, default `80`       | Longitude (in degrees) to center the Robinson projection.                                                                                              |
| `title`             | `str`, optional           | Title of the plot.                                                                                                                                     |
| `alpha`             | `float`, default `0.7`    | Transparency of the primary data points.                                                                                                               |
| `scale`             | `float`, default `10`     | Scale of the velocity vector arrows (larger values produce shorter arrows).                                                                            |
| `save_fig`          | `str`, optional           | File path to save the figure to (300 dpi, tight bounding box). If `None`, the figure is not saved.                                                     |
| `rasterize`         | `bool`, default `True`    | Whether to rasterize the scatter and quiver layers, keeping file sizes small when plotting many points while leaving axes/text as vectors.             |
| `show`              | `bool`, default `True`    | Whether to display the figure with `plt.show()`.                                                                                                       |


---



## `plot_robinson_projection_with_velocity(z_df, colour_by, velocity_df=None, palette=None, ref_df=None, central_longitude=80, title="", alpha=0.7, scale=10)`

**Description:**
Projects 3D spherical coordinates onto a 2D Robinson map with optional RNA velocity overlays and flexible coloring by categorical or continuous metadata. NA values are shown in grey. Used for interpreting global cell state structure or transitions in a biologically interpretable planar projection.

**Example usage:**
```python
plot_robinson_projection_with_velocity(
    z_df=embedding_df,
    colour_by='cell_cycle_pseudotime',
    velocity_df=velocity_df,
    palette='rocket_r',
    ref_df=reference_df,
    title="Differentiation Trajectory",
    scale=15
)
``
`
**Parameters:**
| Parameter           | Type                      | Description                                                                                                                          |
| ------------------- | ------------------------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| `z_df`              | `DataFrame`               | DataFrame containing 3D spherical embedding coordinates (`dim1`, `dim2`, `dim3`) and associated metadata for coloring.               |
| `colour_by`         | `str`                     | Column in `z_df` to color by. Supports both categorical (e.g., `'KNN_phase'`) and continuous (e.g., `'cell_cycle_pseudotime'`) data. |
| `velocity_df`       | `DataFrame`, optional     | Optional RNA velocity DataFrame with `dim1`, `dim2` columns representing directional flow vectors in spherical projection.           |
| `palette`           | `dict` or `str`, optional | Custom palette. Dictionary for categorical data, or colormap name (e.g., `'mako'`, `'viridis'`) for continuous variables.            |
| `ref_df`            | `DataFrame`, optional     | Optional reference DataFrame with `dim1`, `dim2`, `dim3` and `putative_phase_transition` columns. Plots as faint background points.  |
| `central_longitude` | `int`, default `80`       | Longitude (in degrees) to center the Robinson projection.                                                                            |
| `title`             | `str`, optional           | Title of the plot.                                                                                                                   |
| `alpha`             | `float`, default `0.7`    | Transparency of the primary data points.                                                                                             |
| `scale`             | `float`, default `10`     | Scale of the velocity vector arrows.                                                                                                 |



📘 For full tutorials, see the [Python Tutorial](python_tutorial.ipynb).



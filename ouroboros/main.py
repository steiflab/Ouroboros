
import warnings
import os 
warnings.filterwarnings("ignore", category=FutureWarning)

os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'  # 0 = all logs, 1 = info, 2 = warning, 3 = error

progress_frames = [
    """⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣴⡶⢿⣟⡛⣿⢉⣿⠛⢿⣯⡈⠙⣿⣦⡀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⣠⡾⠻⣧⣬⣿⣿⣿⣿⣿⡟⠉⣠⣾⣿⠿⠿⠿⢿⣿⣦⠀⠀⠀
⠀⠀⠀⠀⣠⣾⡋⣻⣾⣿⣿⣿⠿⠟⠛⠛⠛⠀⢻⣿⡇     ⠈⠛⠀⠀⠀
⠀⠀⠀⣸⣿⣉⣿⣿⣿⡿⠋⠀⠀⠀⠀⠀⠀⠀⠈⢿⣇⠀⠀⠀
⠀⠀⢰⣿⣉⣿⣿⣿⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠦⠀⠀⠀
⠀⠀⣾⣏⣿⣿⣿⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⣿⠉⣿⣿⣿⡇⠀⠀⠀⠀
        Data loading""",
    """⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣴⡶⢿⣟⡛⣿⢉⣿⠛⢿⣯⡈⠙⣿⣦⡀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⣠⡾⠻⣧⣬⣿⣿⣿⣿⣿⡟⠉⣠⣾⣿⠿⠿⠿⢿⣿⣦⠀⠀⠀
⠀⠀⠀⠀⣠⣾⡋⣻⣾⣿⣿⣿⠿⠟⠛⠛⠛⠀⢻⣿⡇     ⠈⠛⠀⠀⠀
⠀⠀⠀⣸⣿⣉⣿⣿⣿⡿⠋⠀⠀⠀⠀⠀⠀⠀⠈⢿⣇⠀⠀⠀
⠀⠀⢰⣿⣉⣿⣿⣿⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠦⠀⠀⠀
⠀⠀⣾⣏⣿⣿⣿⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⣿⠉⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⣿⡛⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠸⡿⢻⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⢻⡟⢙⣿⣿⣿⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
        Data loaded""",
    """⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣴⡶⢿⣟⡛⣿⢉⣿⠛⢿⣯⡈⠙⣿⣦⡀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⣠⡾⠻⣧⣬⣿⣿⣿⣿⣿⡟⠉⣠⣾⣿⠿⠿⠿⢿⣿⣦⠀⠀⠀
⠀⠀⠀⠀⣠⣾⡋⣻⣾⣿⣿⣿⠿⠟⠛⠛⠛⠀⢻⣿⡇     ⠈⠛⠀⠀⠀
⠀⠀⠀⣸⣿⣉⣿⣿⣿⡿⠋⠀⠀⠀⠀⠀⠀⠀⠈⢿⣇⠀⠀⠀⠀
⠀⠀⢰⣿⣉⣿⣿⣿⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠦⠀⠀⠀⠀
⠀⠀⣾⣏⣿⣿⣿⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⣿⠉⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⣿⡛⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠸⡿⢻⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⢻⡟⢙⣿⣿⣿⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠻⣿⡋⣻⣿⣿⣿⣦⣤⣀⣀⣀⠀⠀
⠀⠀⠀⠀⠀⠈⠻⣯⣤⣿⠻⣿⣿⣿⣿⣿⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠈⠙⠛⠾⣧⣼⣟⣉⣿⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠉⠀⠀⠀⠀
        Model loaded""",
    """⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀ ⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣴⡶⢿⣟⡛⣿⢉⣿⠛⢿⣯⡈⠙⣿⣦⡀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⣠⡾⠻⣧⣬⣿⣿⣿⣿⣿⡟⠉⣠⣾⣿⠿⠿⠿⢿⣿⣦⠀⠀⠀
⠀⠀⠀⠀⣠⣾⡋⣻⣾⣿⣿⣿⠿⠟⠛⠛⠛⠀⢻⣿⡇     ⠈⠛⠀⠀⠀
⠀⠀⠀⣸⣿⣉⣿⣿⣿⡿⠋⠀⠀⠀⠀⠀⠀⠀⠈⢿⣇⠀⠀⠀⠀
⠀⠀⢰⣿⣉⣿⣿⣿⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠦⠀⠀⠀⠀
⠀⠀⣾⣏⣿⣿⣿⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⣿⠉⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⣿⡛⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⣧⣼⡇⠀⠀
⠀⠀⠸⡿⢻⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣼⣿⣥⣽⠁⠀⠀
⠀⠀⠀⢻⡟⢙⣿⣿⣿⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣾⣿⣧⣸⡏⠀⠀⠀
⠀⠀⠀⠀⠻⣿⡋⣻⣿⣿⣿⣦⣤⣀⣀⣀⣀⣀⣠⣴⣿⣿⢿⣥⣼⠟⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠈⠻⣯⣤⣿⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⠛⣷⣴⡿⠋⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠈⠙⠛⠾⣧⣼⣟⣉⣿⣉⣻⣧⡿⠟⠋⠁⠀⠀⠀⠀⠀⠀⠀
    Cells embedded in VAE sphere """,
    """⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣴⡶⢿⣟⡛⣿⢉⣿⠛⢿⣯⡈⠙⣿⣦⡀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⣠⡾⠻⣧⣬⣿⣿⣿⣿⣿⡟⠉⣠⣾⣿⠿⠿⠿⢿⣿⣦⠀⠀⠀
⠀⠀⠀⠀⣠⣾⡋⣻⣾⣿⣿⣿⠿⠟⠛⠛⠛⠀⢻⣿⡇⢀⣴⡶⡄⠈⠛⠀⠀⠀
⠀⠀⠀⣸⣿⣉⣿⣿⣿⡿⠋⠀⠀⠀⠀⠀⠀⠀⠈⢿⣇⠈⢿⣤⡿⣦⠀⠀⠀⠀
⠀⠀⢰⣿⣉⣿⣿⣿⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠦⠀⢻⣦⠾⣆⠀⠀⠀
⠀⠀⣾⣏⣿⣿⣿⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⣿⡶⢾⡀⠀⠀
⠀⠀⣿⠉⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣧⣼⡇⠀⠀
⠀⠀⣿⡛⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⣧⣼⡇⠀⠀
⠀⠀⠸⡿⢻⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣼⣿⣥⣽⠁⠀⠀
⠀⠀⠀⢻⡟⢙⣿⣿⣿⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣾⣿⣧⣸⡏⠀⠀⠀
⠀⠀⠀⠀⠻⣿⡋⣻⣿⣿⣿⣦⣤⣀⣀⣀⣀⣀⣠⣴⣿⣿⢿⣥⣼⠟⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠈⠻⣯⣤⣿⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⠛⣷⣴⡿⠋⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠈⠙⠛⠾⣧⣼⣟⣉⣿⣉⣻⣧⡿⠟⠋⠁⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀Sphere visualization complete⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"""
]

def show_progress(stage, missing_gene=[]):
    try:
        get_ipython  # Will raise NameError if not in IPython/Jupyter
        import sys
        from IPython.display import clear_output, display
        clear_output(wait=True)
        if stage == len(progress_frames) - 1 and len(missing_gene) != 0:
            warning_message = f"\nWARNING: {len(missing_gene)}/226 genes are missing from the training set. \nThe model is retrained without {missing_gene}, considering including them for higher accuracy"
            message = progress_frames[stage]
            message += warning_message
            print(message)
        else:
            print(progress_frames[stage])
    except (NameError, ImportError):
        # CLI fallback
        print("\033c", end="")  # Terminal clear
        if stage == len(progress_frames) - 1 and len(missing_gene) != 0:
            warning_message = f"\nWARNING: {len(missing_gene)}/226 genes are missing from the training set. \nThe model is retrained without {missing_gene}, considering including them for higher accuracy"
            message = progress_frames[stage]
            message += warning_message
            print(message)
        else:
            print(progress_frames[stage])

 
def run_ouroboros(data, data_type, species = 'human', outdir = '.', seed = 0, repeat = 1, force=False):
    """
    Run the full Ouroboros pipeline for projecting single-cell expression data
    into VAE spherical embedding space and using KNN to compute cell cycle phase, pseudotime and dormancy pseudotime.

    Parameters
    ----------
    data : str 
        Path to input file (needs to be either a 'h5ad' or a 'csv')
        - For 'h5ad': Anndata object
        - For 'csv' : expects a CSV with cells as rows and genes as columns, with a 'cell_id' index column - must be RAW COUNTS

    data_type : str
        Format of the input data, must be either 'h5ad' or 'csv'

    species : str {'human', 'mouse'}, optional (default='human')
        Species of origin. If 'mouse', gene names will be mapped to human orthologs.

    outdir : str, optional (default='.')
        Output directory where embedding and pseudotime files will be saved.

    Returns
    -------
    z_df : pandas.DataFrame
        A dataframe containing the spherical embedding coordinates (dim1, dim2, dim3),
        predicted states, and dormancy pseudotime for each cell.

    Outputs
    -------
    - ouroboros_embeddings_pseudotimes.csv
    - retrained_reference_embeddings.csv (if retraining is triggered)

    Notes
    -----
    - If key training genes are missing from the input data, the model will be retrained
      on the subset of genes available.
    - The output embeddings and pseudotimes can be used for visualization and downstream analysis.

    Example
    -------
    >>> run_ouroboros("sample.h5ad", "h5ad", species="human", outdir="results/")
    >>> python -m Ouroboros_pypi.Ouroboros.main \
    --data adata.h5ad  \
    --data_type h5ad \
    --species mouse \
    --outdir /path/to/outdir
    """
    show_progress(0)

    from scipy.sparse import issparse
    import numpy as np
    from . import ouroboros_functions as obof
    
    if data_type == 'h5ad':
        import anndata as ad
        data = ad.read_h5ad(data)
        if "raw_counts" in data.layers:
            data.X = data.layers['raw_counts'].copy()
        # densify: downstream - some calls can't handle sparse X
        if issparse(data.X):
            data.X = data.X.toarray()
        X = data.X
        
    elif data_type == 'csv':
        import pandas as pd
        data = pd.read_csv(data)
        if "cell_id" in data.columns:
            data = data.set_index('cell_id')
        elif "Unnamed: 0" in data.columns:
            data = data.set_index('Unnamed: 0')
        X = data.values

    else: 
        raise TypeError("Unsupported data type. Expected --h5ad or --csv for data_type.")

    # Check for raw counts   
    if not force:
        if not (np.all(np.isfinite(X)) & np.all(X >= 0) & np.all(X == np.floor(X))):
            raise ValueError(
                "Expression matrix contains non-integer values or negative values. "
                "Please check if matrix is raw counts and not normalized or log-transformed.\n"
                "You can rerun Ouroboros with --force to ignore this message and continue."
            )
        
    if species == 'mouse':
        logger.info('Converting mouse genes to human orthologs...')
        data = obof.convert_to_human_genes(data)
        logger.info('Genes successfully converted to human orthologs')
    elif species == 'human':
        pass
    else:
        raise TypeError("Unsupported species. Model only optimized for --human or --mouse")

    missing = obof.check_features(data)

    if not force and len(missing) > 50:
        raise ValueError(
            f"{len(missing)}/226 training genes seem to be missing from your dataset.\n"
            f"Missing genes include: {missing}\n\n"
            "For higher accuracy, consider including these genes in the matrix "
            "and running Ouroboros again.\n"
            "You can rerun Ouroboros with --force to ignore this message and continue."
        )

    show_progress(1)
    os.makedirs(outdir, exist_ok=True) 
    
    if len(missing) > 0:
        logger.warning(f"""Key training genes seem to be missing from your dataset\n
              Missing genes include: {missing}
              For higher accuracy consider including these genes in the matrix and running Ouroboros again.
              Retraining model without them......""")
        for i in range(repeat):
            curr_seed = seed + i
            curr_outdir = outdir + "/retrain/" + str(i)
            os.makedirs(curr_outdir, exist_ok=True)
            model, ref_embed, in_order_feature_set, trainer_model = obof.ouroboros_retrain(data, curr_seed)
            model.save_sess(f'{curr_outdir}/model')

            show_progress(2)
            z_df = obof.embed_in_retrained_sphere(data, model, in_order_feature_set)
            show_progress(3)
            z_df = obof.KNN_predict(ref_embed, z_df)
        
            z_df = obof.calculate_cell_cycle_pseudotime(z_df, ref_embed,  phase_category = 'KNN_phase')
            pseud, ref_pseud = obof.dormancy_depth(z_df, ref_embed, retrained = True)
            z_df = z_df.merge(pseud, how = 'left', left_index = True, right_index = True)
            z_df = obof.qc_and_threshold(model, trainer_model, z_df, in_order_feature_set, ref_embed, curr_outdir, seed)
            # rotate so N pole is [0,0,1] for nice plotting
            N_pole = obof.find_cycle_pole(ref_embed)
            ref_embed = obof.rotate_north(ref_embed, reference_CC_pole_point = N_pole)
            ref_embed.to_csv(f'{curr_outdir}/retrained_reference_embeddings.csv')
            z_df = obof.rotate_north(z_df, reference_CC_pole_point = N_pole)
            z_df.to_csv(f'{curr_outdir}/ouroboros_embeddings_pseudotimes.csv')

        z_df, ref_embed = obof.select_seed(repeat, outdir)
    else:
        import pandas as pd
        logger.info('All training genes present, embedding your cells in VAE latent space...')
        matrix = obof.ouroboros_preprocess(data, data_type)
        show_progress(2)
        z_df = obof.ouroboros_embed(matrix, data, data_type, outdir = outdir)
        show_progress(3)
        # Read in known reference embeddings 
        ref_embed = pd.read_csv(obof.DATA_DIR / 'reference_embeddings.csv')
        # set cell id to be index
        ref_embed = ref_embed.set_index('cell_id')
        # Rotate so north is always [0,0,1]
        N_pole = obof.find_cycle_pole(ref_embed)
        z_df = obof.rotate_north(z_df, reference_CC_pole_point = N_pole)
        z_df.to_csv(f'{outdir}/ouroboros_embeddings_pseudotimes.csv')
        ref_embed = obof.rotate_north(ref_embed, reference_CC_pole_point = N_pole)


    z_df = obof.add_annotation(z_df)
    z_df.to_csv(f'{outdir}/ouroboros_embeddings_pseudotimes.csv')

    try:
        obof.plot_sphere(z_df, colour_by = 'cell_cycle_pseudotime', palette = None, ref = ref_embed, velocity = None, marker_size = 2, cycle_pole = [0,0,1], savefig = f'{outdir}/ouroboros_cell_cycle_pseudotime.html', show = False)
    except ValueError as e:
        logger.info(f"Caught error in cell_cycle_pseudotime plot: {e}")
    try:
        obof.plot_sphere(z_df, colour_by = 'dormancy_pseudotime', palette = None, ref = ref_embed, velocity = None, marker_size = 2, cycle_pole = [0,0,1], savefig = f'{outdir}/ouroboros_dormancy_pseudotime.html', show = False)
    except ValueError as e:
        logger.info(f"Caught error in dormancy_pseudotime plot: {e}")
    try:
        obof.plot_sphere(z_df, colour_by = 'KNN_phase', palette = None, ref = ref_embed, velocity = None, marker_size = 2, cycle_pole = [0,0,1], savefig = f'{outdir}/ouroboros_KNN_phase.html', show = False)
    except ValueError as e:
        logger.info(f"Caught error in KNN_phase plot: {e}")

    try:
        obof.plot_pseudotime(z_df, save_fig = f'{outdir}/pseudotime_histogram.png')
    except ValueError as e:
        logger.info(f"Caught error in pseudotime histogram plot: {e}")

    show_progress(4, missing)
    return z_df
    

def main():
    import argparse
    import logging
    import os

    os.makedirs("logs", exist_ok=True)

    logging.basicConfig(
        filename="logs/ouroboros_run.log",
        filemode="w",
        level=logging.INFO,
        format="%(asctime)s - %(levelname)s - %(message)s"
    )

    parser = argparse.ArgumentParser()
    parser.add_argument("--data", required=True)
    parser.add_argument("--data_type", choices=["csv", "h5ad"], required=True)
    parser.add_argument("--species", default="human")
    parser.add_argument("--outdir", default=".")
    parser.add_argument("--seed", type=int, default=0)
    parser.add_argument("--repeat", type=int, default=1)
    parser.add_argument("--force", action="store_true")
    args = parser.parse_args()

    run_ouroboros(args.data, args.data_type, species=args.species, outdir=args.outdir, seed=args.seed, repeat=args.repeat, force=args.force)


if __name__ == "__main__":
    main()

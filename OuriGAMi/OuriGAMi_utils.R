suppressPackageStartupMessages({
  library(mgcv)
  library(scuttle)
  library(scran)
  library(zellkonverter)
  library(furrr)
  library(future)
  library(dplyr)
  library(readr)
  library(progressr)
  library(ggplot2)
  library(purrr)
  library(reticulate)
})

read_adata <- function(adata_path) {
  anndata <- import("anndata")
  adata <- anndata$read_h5ad(adata_path)
  sce <- AnnData2SCE(adata)
  return(sce)
}

read_files <- function(sce, meta, obo_path, genes, assay_type="logcounts") {
  obo <- read_delim(obo_path, show_col_types = FALSE)
  meta <- obo %>%
    dplyr::mutate(pseudotime = case_when(
      south ~ dormancy_pseudotime,
      T ~ cell_cycle_pseudotime
    )) %>%
    dplyr::rename('cell' = '...1') %>%
    inner_join(meta, by = 'cell') %>%
    dplyr::filter(!is.na(exp)) %>%
    dplyr::filter(cell %in% colnames(sce))
  
  counts <- assay(sce, assay_type)
  expr_mat <- counts[genes, meta$cell, drop = FALSE]
  expr_mat <- as.matrix(expr_mat)
  
  return(list(expr_mat = expr_mat, meta = meta, genes = genes))
}

bin_files <- function(files, type, bin_size=30) {
  meta <- files$meta
  expr_mat <- files$expr_mat
  genes <- files$genes
  
  if (type == 'dormancy') {
    dorm=TRUE
  } else if (type == 'cell_cycle') {
    dorm=FALSE
  } else {
    stop("Type must be 'dormancy' or 'cell_cycle'")
  }
  
  binned_meta <- meta %>%
    dplyr::filter(south == dorm) %>%
    arrange(exp, pseudotime) %>%  
    group_by(exp) %>%
    mutate(
      bin = rep(
        seq_len(ceiling(n() / bin_size)),
        each = bin_size,
        length.out = n()
      )
    ) %>%
    group_by(exp, bin) %>%
    summarise(
      avg_pseudotime = mean(pseudotime),
      cells = list(cell),
      .groups = "drop"
    )
  
  
  bins <- paste(binned_meta$exp, binned_meta$bin, sep = "_")  # e.g., "nsg_1"
  binned_mat <- matrix(0, nrow = length(genes), ncol = length(bins),
                       dimnames = list(genes, bins))
  for (i in seq_along(binned_meta$cells)) {
    cells_in_bin <- binned_meta$cells[[i]]
    
    cells_in_bin <- intersect(cells_in_bin, colnames(expr_mat))
    binned_mat[, i] <- rowMeans(expr_mat[genes, cells_in_bin, drop = FALSE])
  }
  return(list(binned_mat=binned_mat, binned_meta=binned_meta, type=type))
}

fit_GAM <- function(df, type, family_function=gaussian(), k=10) {
  single_exp <- nlevels(df$exp) <= 1  # use nlevels, not length(unique())
  
  if (type == 'cell_cycle') {
    if (single_exp) {
      fit <- gam(gene_counts ~ s(avg_pseudotime, k=k, bs="cc"),
                 family=family_function, method="REML",
                 knots=list(avg_pseudotime=c(0,1)), data=df)
    } else {
      fit <- gam(gene_counts ~ exp +
                   s(avg_pseudotime, k=k, bs="cc") +
                   s(avg_pseudotime, by=exp, k=k, bs="cc"),
                 family=family_function, method="REML",
                 knots=list(avg_pseudotime=c(0,1)), data=df)
    }
  } else if (type == 'dormancy') {
    if (single_exp) {
      fit <- gam(gene_counts ~ s(avg_pseudotime, k=k),
                 family=family_function, method="REML",
                 knots=list(avg_pseudotime=c(-1,0)), data=df)
    } else {
      fit <- gam(gene_counts ~ exp +
                   s(avg_pseudotime, k=k) +
                   s(avg_pseudotime, by=exp, k=k),
                 family=family_function, method="REML",
                 knots=list(avg_pseudotime=c(-1,0)), data=df)
    }
  } else {
    stop("Type must be 'dormancy' or 'cell_cycle'")
  }
  return(fit)
}

get_peak <- function(fit, meta, exp){
  newdf <- expand.grid(
    avg_pseudotime = seq(min(meta$avg_pseudotime),max(meta$avg_pseudotime),
                         length.out = 200),
    exp = exp
  )
  newdf$pred <- predict(fit, newdata = newdf)
  return(newdf[which.max(newdf$pred), ]$avg_pseudotime)
}

parsing_GAM <- function(fit, gene, type, meta){
  
  s_table <- summary(fit)$s.table
  p_table <- summary(fit)$p.table
  
  
  R2_adj <- summary(fit)$r.sq
  dev_expl <- summary(fit)$dev.expl
  
  # Main smooth
  main_p <- s_table['s(avg_pseudotime)', "p-value"]
  main_edf <- s_table['s(avg_pseudotime)', "edf"]
  
  exp_cols <- list()
  if (length(unique(meta$exp)) == 1){
    curr_exp <- unique(meta$exp)
    exp_cols[["peak"]] <- get_peak(fit, meta, curr_exp)
  } else {
    for (curr_exp in unique(meta$exp)){
      exp_cols[[paste0(curr_exp, "_p")]]   <- s_table[paste0('s(avg_pseudotime):exp', curr_exp), "p-value"]
      exp_cols[[paste0(curr_exp, "_edf")]] <- s_table[paste0('s(avg_pseudotime):exp', curr_exp), "edf"]
      exp_cols[[paste0(curr_exp, "_contrast_p")]] <- tryCatch(
        p_table[paste0('exp', curr_exp), 'Pr(>|t|)'],
        error = function(e) tryCatch(
          p_table[paste0('exp', curr_exp), 'Pr(>|z|)'],
          error = function(e) NA
        )
      )
      exp_cols[[paste0(curr_exp, "_peak")]] <- get_peak(fit, meta, curr_exp)
    }
  }
  
  metrics <- tibble(
    gene = gene,
    pseudotime = type,
    R2 = R2_adj,
    deviance = dev_expl,
    main_p = main_p, 
    main_edf = main_edf,
    !!!exp_cols
  )
  return(metrics)
}

run_GAM <- function(binned_files, type, genes, threads=16, family_function=gaussian(), k=10, ref_exp=NULL){
  on.exit(plan(sequential), add = TRUE)
  binned_mat <- binned_files$binned_mat
  binned_meta <- binned_files$binned_meta
  
  plan("multisession", workers = threads)
  
  metrics <- with_progress({
    p <- progressor(steps = length(genes))
    
    future_map(genes, function(gene) {
      p()
      tryCatch({
        df <- binned_meta
        df$gene_counts <- binned_mat[gene, ]
        df$exp <- factor(df$exp)
        if (!is.null(ref_exp)){
          df$exp <- relevel(df$exp, ref = ref_exp)
        }
        fit <- fit_GAM(df, type, family_function, k)
        parsing_GAM(fit, gene, type, binned_meta)
      }, error = function(e) {
        tibble(gene = gene, error=conditionMessage(e))
      })
    }) %>%
      dplyr::bind_rows()
  })
  
  return(metrics)
}

plot_gene <- function(gene, binned_files) {
  binned_mat <- binned_files$binned_mat
  binned_meta <- binned_files$binned_meta
  type <- binned_files$type
  
  df <- binned_meta
  df$gene_counts <- binned_mat[gene, ]
  df$exp <- factor(df$exp)
  fit <- fit_GAM(df, type, family_function, k)
  
  newdf <- expand.grid(
    avg_pseudotime = seq(min(df$avg_pseudotime),
                         max(df$avg_pseudotime),
                         length.out = 200),
    exp = levels(df$exp)
  )
  newdf$pred <- predict(fit, newdata = newdf, type = "response")
  
  ymax <- max(df$gene_counts, na.rm = TRUE)
  bar_y    <- ymax * 1.02   # bottom of color bars
  bar_h    <- ymax * 0.02   # height of color bars
  label_y  <- ymax * 1.045  # y position of phase labels
  
  # Phase definitions (mirrors your Python dict)
  if (type == 'dormancy') {
    phase_colors <- c(
      Light = 'lightgrey',
      Mid   = 'darkgrey',
      Deep  = 'black'
    )
    phase_regions <- list(
      Light = c(-0.4, 0),
      Mid   = c(-0.6, -0.4),
      Deep  = c(-1,   -0.6)
    )
  } else if (type == 'cell_cycle') {
    phase_colors <- c(
      G1    = '#1f77b4',
      S     = '#ff7f0e',
      G2M   = '#2ca02c'
    )
    phase_regions <- list(
      G1    = c(0,    0.4),
      S     = c(0.4,  0.75),
      G2M   = c(0.75, 1)
    )
  }
  
  # Build annotation data frames
  rect_df <- do.call(rbind, lapply(names(phase_regions), function(ph) {
    data.frame(
      xmin  = phase_regions[[ph]][1],
      xmax  = phase_regions[[ph]][2],
      ymin  = bar_y,
      ymax  = bar_y + bar_h,
      fill  = phase_colors[ph],
      stringsAsFactors = FALSE
    )
  }))
  
  text_df <- do.call(rbind, lapply(names(phase_regions), function(ph) {
    data.frame(
      x     = mean(phase_regions[[ph]]),
      y     = label_y,
      label = ph,
      stringsAsFactors = FALSE
    )
  }))
  
  
  ggplot(df, aes(avg_pseudotime, gene_counts, color = exp)) +
    geom_point(alpha = 0.4) +
    geom_line(data = newdf,
              aes(avg_pseudotime, pred, color = exp),
              linewidth = 1) +
    
    # ── Phase color bars ──────────────────────────────────────────────────────
    geom_rect(
      data = rect_df,
      aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
      fill  = rect_df$fill,
      color = NA,
      inherit.aes = FALSE
    ) +
    geom_text(
      data = text_df,
      aes(x = x, y = y, label = label),
      inherit.aes = FALSE,
      fontface = "bold", size = 3.5, vjust = 0
    ) +
    
    # ── Expand plot limits so bars and labels aren't clipped ─────────────────
    coord_cartesian(clip = "off") +
    scale_y_continuous(expand = expansion(mult = c(0.05, 0.12))) +
    
    ggtitle(gene, subtitle = type) +
    theme(plot.margin = margin(t = 20, r = 10, b = 30, l = 10))
}


get_gam_predictions <- function(curr_gene, meta_binned, binned_mat, type) {
  df <- meta_binned
  df$gene_counts <- binned_mat[curr_gene, ]
  df$exp <- factor(df$exp)
  
  fit <- fit_GAM(df, type, family_function, k)
  
  # Predictions
  newdf <- expand.grid(
    avg_pseudotime = seq(min(df$avg_pseudotime),
                         max(df$avg_pseudotime),
                         length.out = 200),
    exp = levels(df$exp)
  )
  
  newdf$pred <- predict(fit, newdata = newdf, type = "response")
  newdf$gene <- curr_gene
  df$gene <- curr_gene
  
  list(obs = df, pred = newdf)
}

plot_multi_genes <- function(top_genes, metrics, binned_files, type) {
  binned_mat  <- binned_files$binned_mat
  meta_binned <- binned_files$binned_meta
  
  all_data <- map(top_genes, function(gene) {
    get_gam_predictions(gene, meta_binned, binned_mat, type)
  })
  
  obs_df  <- map_dfr(all_data, "obs")
  pred_df <- map_dfr(all_data, "pred")
  
  obs_df$gene  <- factor(obs_df$gene,  levels = top_genes)
  pred_df$gene <- factor(pred_df$gene, levels = top_genes)
  
  # ── Phase definitions ──────────────────────────────────────────────────────
  if (type == "dormancy") {
    phase_colors  <- c(Light = "lightgrey", Mid = "darkgrey", Deep = "black")
    phase_regions <- list(Light = c(-0.4, 0), Mid = c(-0.6, -0.4), Deep = c(-1, -0.6))
  } else if (type == "cell_cycle") {
    phase_colors  <- c(G1 = "#1f77b4", S = "#ff7f0e", G2M = "#2ca02c")
    phase_regions <- list(G1 = c(0, 0.4), S = c(0.4, 0.75), G2M = c(0.75, 1))
  }
  
  # ── Per-gene ymax table ────────────────────────────────────────────────────
  gene_ymax <- obs_df |>
    group_by(gene) |>
    summarise(ymax = max(gene_counts, na.rm = TRUE), .groups = "drop")
  
  # ── Build per-facet annotation frames ─────────────────────────────────────
  phase_base <- do.call(rbind, lapply(names(phase_regions), function(ph) {
    data.frame(
      xmin  = phase_regions[[ph]][1],
      xmax  = phase_regions[[ph]][2],
      label = ph,
      fill  = phase_colors[ph],
      stringsAsFactors = FALSE
    )
  }))
  
  # Cross-join phases × genes, then scale y positions per gene
  rect_df <- merge(phase_base, gene_ymax) |>
    mutate(
      ymin_bar = ymax * 1.02,
      ymax_bar = ymax * 1.04,
      gene     = factor(gene, levels = top_genes)
    )
  
  text_df <- rect_df |>
    mutate(
      x       = (xmin + xmax) / 2,
      y_label = ymax * 1.05
    )
  
  # ── Plot ───────────────────────────────────────────────────────────────────
  ggplot() +
    geom_point(
      data = obs_df,
      aes(x = avg_pseudotime, y = gene_counts, color = exp),
      alpha = 0.4, size = 0.1
    ) +
    geom_line(
      data = pred_df,
      aes(x = avg_pseudotime, y = pred, color = exp),
      linewidth = 1
    ) +
    geom_rect(
      data = rect_df,
      aes(xmin = xmin, xmax = xmax, ymin = ymin_bar, ymax = ymax_bar),
      fill        = rect_df$fill,
      color       = NA,
      inherit.aes = FALSE
    ) +
    geom_text(
      data = text_df,
      aes(x = x, y = y_label, label = label),
      inherit.aes = FALSE,
      fontface = "bold", size = 2.5, vjust = 0
    ) +
    facet_wrap(~gene, scales = "free_y") +
    coord_cartesian(clip = "off") +
    scale_y_continuous(expand = expansion(mult = c(0.05, 0.12))) +
    theme_minimal() +
    labs(x = "Average Pseudotime", y = "Expression", color = "Experiment") +
    theme(
      strip.text   = element_text(size = 10),
      plot.margin  = margin(t = 20, r = 10, b = 10, l = 10)
    )
}


score_gene_set <- function(mat, gene_set, set_name) {
  genes <- intersect(rownames(mat), gene_set)
  if (length(genes) == 0) {
    print(paste0('No ', set_name, " genes in expression matrix"))
    return(rep(NA, ncol(mat)))
  }
  
  Matrix::colMeans(mat[genes, , drop = FALSE])
}

get_gene_set <- function(files, gene_sets){
  expr_mat <- files$expr_mat
  scores <- imap(gene_sets, function(gs, set_name) {
    score_gene_set(expr_mat, gs, set_name)
  })
  
  score_mat <- do.call(cbind, scores)
  colnames(score_mat) <- names(gene_sets)
  score_mat <- t(score_mat)
  return(list(score_mat = score_mat, gene_sets = names(gene_sets)))
}


ouroboros_genes <- c(
  "BUB1", "H1-3", "KIF4A", "SNCG", "AURKB", "YPEL3", "HMMR", "ECT2", "CENPF", "SPON2",
  "ZNF469", "SH3RF2", "IL17RE", "PTGS1", "H4C8", "RHOV", "IGFBP5", "TTK", "CDC6", "ASPM",
  "CXCL12", "CXXC4", "F10", "CLTRN", "MKI67", "MCM4", "KIF20A", "BUB1B", "PSMC3IP", "VCAN",
  "CKAP2L", "CLIP3", "CCNE1", "CCNB2", "ISL1", "NUF2", "KPNA2", "KIF20B", "SGO1", "WDR76",
  "PYY", "GTSE1", "ABCC3", "CCNB1", "UNG", "RACGAP1", "UGT8", "SGO2", "CIT", "CDC25C",
  "PLD4", "E2F8", "POLD3", "LRRC4C", "MEIS1", "H1-5", "PCDH18", "H1-1", "MASP1", "TOP2A",
  "KIF18B", "RAD51", "PHLDA1", "COL3A1", "DTL", "PAQR4", "SGIP1", "MAFB", "PPP1R14A", "RGCC",
  "CD24", "EXO1", "HJURP", "IQGAP3", "SLC22A18", "SOX6", "RAPSN", "PDGFRB", "NCAPH", "CDCA3",
  "ZNF367", "IGF2", "HEPACAM2", "HMGB2", "CDK1", "ANKRD1", "SYNE2", "WNT5B", "DSN1", "TSPAN7",
  "ACTA2", "FAM111A", "BRCA1", "MCM6", "GHRL", "DIAPH3", "CCNE2", "TCF19", "H2AC20", "CENPA",
  "PIMREG", "CDKN1C", "SERPING1", "GINS2", "VWA5B2", "UBE2S", "NEK2", "KIF23", "APOE", "GAS2L3",
  "INCENP", "ATAD2", "KLF6", "MCM3", "MCM5", "ARL6IP1", "SPON1", "MXD4", "KIF18A", "PCNA",
  "PCSK1", "LUM", "TPX2", "GSN", "POLA2", "BLM", "NRARP", "UBE2C", "FLRT1", "RRM2",
  "SULF1", "WDHD1", "TNFRSF11B", "MCM2", "KIF11", "RAB27B", "NUSAP1", "MCM10", "KRT17", "CDCA7",
  "ARID5B", "KIF14", "SYTL4", "OSBPL6", "L1CAM", "ERCC6L", "STIL", "VILL", "PDCD4", "NDC80",
  "SHF", "NEUROD2", "VAMP5", "NEURL1B", "ORC1", "MMS22L", "CHAF1A", "KIF2C", "DLGAP5", "YPEL2",
  "CLDN9", "MELK", "TICRR", "CLSPN", "CENPE", "TROAP", "DNMT3B", "NR5A2", "KNSTRN", "PLK1",
  "CRYBA2", "CDC45", "FAM83D", "CMTM8", "AURKA", "CDC20", "E2F1", "CLDN7", "PALMD", "CLDN6",
  "NECAB2", "FAM43A", "H1-4", "CHGB", "CKAP2", "SPRY1", "MFSD3", "KIAA0040", "CEP55", "DEPDC1",
  "FBXO5", "CDCA8", "HYLS1", "AMBP", "FCGRT", "H2BC11", "BCL2L14", "PIF1", "KNL1", "FGFR3",
  "SAPCD2", "ARRDC3", "HELLS", "HOXB5", "ENHO", "TRPV2", "UBALD2", "FEN1", "CDCA2", "BRIP1",
  "ESCO2", "RFC4", "PIGW", "SLFN11", "CCNF", "PSRC1", "IRAG1", "PLCXD3", "CCNA2", "TONSL",
  "DHRS13", "SPAG5", "MGARP", "SLBP", "PCSK1N", "CDKN2D"
)

                  
read_adata <- function(adata_path) {
  anndata <- import("anndata")
  adata <- anndata$read_h5ad(adata_path)
  sce <- AnnData2SCE(adata)
  return(sce)
}

read_files <- function(sce, meta, obo_path, genes, assay_type="logcounts") {
  obo <- read_delim(obo_path, show_col_types = FALSE) 
  
  if ('dormancy_depth' %in% colnames(obo)) {
    obo <- rename(obo, dormancy_pseudotime = dormancy_depth)
  }
  
  obo <- obo %>%
    dplyr::select(...1, dim1,dim2,dim3,KNN_phase,cell_cycle_pseudotime,south,dormancy_pseudotime) %>%
    dplyr::mutate(pseudotime = case_when(
      south ~ dormancy_pseudotime,
      T ~ cell_cycle_pseudotime
    )) %>%
    dplyr::rename('cell' = '...1')
  
  if (length(meta) == 1 && is.na(meta)) {
    meta <- obo %>%
      dplyr::mutate(exp = 'cells')
  } else {
    meta <- obo %>%
      inner_join(meta, by = 'cell') %>%
      dplyr::filter(!is.na(exp)) 
  }

  meta <- meta %>%
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
  } else if (type == 'all') {
    dorm <- c(TRUE, FALSE)
  } else {
    stop("Type must be 'dormancy', 'cell_cycle' or 'all'")
  }
  
  group_vars <- if ("patient_id" %in% colnames(meta)){
     c("exp", "patient_id") 
  } else "exp"
  
  binned_meta <- meta %>%
    dplyr::filter(south %in% dorm) %>%
    arrange(pseudotime) %>%  
    group_by(across(all_of(group_vars))) %>%
    mutate(
      bin = rep(
        seq_len(ceiling(n() / bin_size)),
        each = bin_size,
        length.out = n()
      )
    ) %>%
    group_by(across(all_of(c(group_vars, "bin")))) %>%
    summarise(
      avg_pseudotime = mean(pseudotime),
      cells = list(cell),
      .groups = "drop"
    )
  
  if ("patient_id" %in% colnames(meta)){
    bins <- paste(binned_meta$exp, binned_meta$patient_id,binned_meta$bin, sep = "_")  
  } else {
    bins <- paste(binned_meta$exp, binned_meta$bin, sep = "_")  # e.g., "nsg_1"  
  }
  
  binned_mat <- matrix(0, nrow = length(genes), ncol = length(bins),
                       dimnames = list(genes, bins))
  for (i in seq_along(binned_meta$cells)) {
    cells_in_bin <- binned_meta$cells[[i]]
    
    cells_in_bin <- intersect(cells_in_bin, colnames(expr_mat))
    binned_mat[, i] <- rowMeans(expr_mat[genes, cells_in_bin, drop = FALSE])
  }
  return(list(binned_mat=binned_mat, binned_meta=binned_meta, type=type))
}

fit_GAM <- function(df, type, family_function=gaussian(), k=10, cyclic_cubic=FALSE) {
  
  # Set pseudotime range based on cell cycle or dormant
  pseudotime_range <- if (type == 'cell_cycle') {
    c(0,1)
  } else if (type == 'dormancy') {
    c(-1,0)
  }  else if (type == 'all') {
    c(-1,1)
  } else stop("Type must be 'dormancy' or 'cell_cycle'")
  
  # Check to use cyclic cubic spline or thin plate spline
  spline <- if (cyclic_cubic) "cc" else "tp"
  
  base_terms <- sprintf("s(avg_pseudotime, k=%d, bs='%s') +", k, spline)
  
  # Check if more than one exp condition 
  single_exp <- nlevels(df$exp) <= 1
  if (!single_exp) {
    exp_fixed <- "exp +"
    exp_term <- sprintf("s(avg_pseudotime, by=exp,k=%d, bs='%s') +", k, spline)
  } else {
    exp_fixed <- ""
    exp_term <- ""
  }
  
  # Check for whether to use patient as co-variate
  if ("patient_id" %in% colnames(df)) {
    patient_term <- "s(patient_id, bs='re') +"
  } else {
    patient_term <- ''
  }
  
  # Dynamically build GAM formula
  formula_str <- paste("gene_counts ~ ", exp_fixed, base_terms, exp_term, patient_term, sep="")
  formula_str <- substr(formula_str, 1, nchar(formula_str) - 2)
  
  form <- as.formula(formula_str)
  
  fit <- gam(form,
             family=family_function, method="REML",
             knots=list(avg_pseudotime=pseudotime_range), data=df)
  return(fit)
}

get_peak <- function(fit, meta, exp){
  newdf <- expand.grid(
    avg_pseudotime = seq(min(meta$avg_pseudotime),max(meta$avg_pseudotime),
                         length.out = 200),
    exp = exp
  )

  if ("patient_id" %in% names(fit$model)) {
    lev <- levels(fit$model$patient_id)
    newdf$patient_id <- factor(rep(lev[1], nrow(newdf)),
                               levels = lev)
  }
  
  # Exclude the patient random-effect term so predictions reflect population-level fit
  exclude_terms <- if ("patient_id" %in% names(fit$model)) "s(patient_id)" else NULL
  
  newdf$pred <- predict(fit, newdata = newdf, exclude = exclude_terms)
  
  return(newdf[which.max(newdf$pred), ]$avg_pseudotime)
}

peak_region <- function(peak) {
  as.character(cut(
    peak,
    breaks = c(-1, -0.6, -0.4, 0, 0.4, 0.75, 1),
    labels = c("deep_dorm", "mid_dorm", "light_dorm", "G1", "S", "G2M"),
    right = FALSE,        # intervals are [a, b)
    include.lowest = TRUE # -1 is included; last interval becomes [0.75, 1] closed
  ))
}

get_main_peak <- function(fit, meta){
  newdf <- expand.grid(
    avg_pseudotime = seq(min(meta$avg_pseudotime), max(meta$avg_pseudotime),
                         length.out = 200)
  )
  # exp must exist in newdata even though its effect will be excluded
  newdf$exp <- levels(factor(meta$exp))[1]
  
  if ("patient_id" %in% names(fit$model)) {
    lev <- levels(fit$model$patient_id)
    newdf$patient_id <- factor(rep(lev[1], nrow(newdf)),
                               levels = lev)
  }
  
  # Exclude patient random effect AND all exp-specific interaction smooths,
  # so predictions reflect only the main s(avg_pseudotime) term
  s_labels <- rownames(summary(fit)$s.table)
  exclude_terms <- s_labels[
    grepl("^s\\(patient_id\\)$", s_labels) |
      grepl("^s\\(avg_pseudotime\\):exp", s_labels)
  ]
  if (length(exclude_terms) == 0) exclude_terms <- NULL
  
  newdf$pred <- predict(fit, newdata = newdf, exclude = exclude_terms)
  
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
    peak <- get_peak(fit, meta, curr_exp)
    exp_cols[["peak"]] <- peak
    exp_cols[["peak_region"]] <- peak_region(peak)
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
      peak <- get_peak(fit, meta, curr_exp)
      exp_cols[[paste0(curr_exp, "_peak")]] <- peak
      exp_cols[[paste0(curr_exp, "_peak_region")]] <- peak_region(peak)
    }
  }
  
  if ("s(patient_id)" %in% rownames(s_table)) {
    exp_cols[['patient_edf']] <- s_table['s(patient_id)', "edf"]
    exp_cols[['patient_p']] <- s_table['s(patient_id)', "p-value"]
  } 
  
  main_peak <- get_main_peak(fit, meta)
  
  metrics <- tibble(
    gene = gene,
    pseudotime = type,
    R2 = R2_adj,
    deviance = dev_expl,
    main_p = main_p, 
    main_edf = main_edf,
    main_peak = main_peak,
    main_peak_region = peak_region(main_peak),
    !!!exp_cols
  )
  return(metrics)
}

run_GAM <- function(binned_files, type, genes, threads=16, family_function=gaussian(), k=10, ref_exp=NULL, cyclic_cubic=F){
  on.exit(plan(sequential), add = TRUE)
  binned_mat <- binned_files$binned_mat
  binned_meta <- binned_files$binned_meta
  
  if (length(unique(binned_meta$exp)) == 1){
    ref_exp=NULL
  }
  
  plan("multisession", workers = threads)
  
  gene_counts_list <- setNames(
    lapply(genes, function(g) binned_mat[g, ]),
    genes
  )
  
  metrics <- with_progress({
    p <- progressor(steps = length(genes))
    
    future_map2(genes, gene_counts_list, function(gene, count) {
      p()
      tryCatch({
        df <- binned_meta
        df$gene_counts <- count
        df$exp <- factor(df$exp)
        if ('patient_id' %in% colnames(df)) {
          df$patient_id <- factor(df$patient_id)
        }
        if (!is.null(ref_exp)){
          df$exp <- relevel(df$exp, ref = ref_exp)
        }
        fit <- fit_GAM(df, type, family_function, k, cyclic_cubic)
        parsing_GAM(fit, gene, type, binned_meta)
      }, error = function(e) {
        tibble(gene = gene, error=conditionMessage(e))
      })
    }) %>%
      dplyr::bind_rows()
  })
  
  return(metrics)
}

fit_LM <- function(df) {
  
  base_terms <- "avg_pseudotime +"
  
  # Check if more than one exp condition
  single_exp <- nlevels(df$exp) <= 1
  if (!single_exp) {
    exp_fixed <- "exp +"
    exp_term <- "avg_pseudotime:exp +"
  } else {
    exp_fixed <- ""
    exp_term <- ""
  }
  
  # Check for whether to use patient as co-variate (fixed effect, since lm has no random effects)
  if ("patient_id" %in% colnames(df)) {
    patient_term <- "patient_id +"
  } else {
    patient_term <- ""
  }
  
  # Dynamically build linear model formula
  formula_str <- paste("gene_counts ~ ", exp_fixed, base_terms, exp_term, patient_term, sep = "")
  formula_str <- substr(formula_str, 1, nchar(formula_str) - 2)
  
  form <- as.formula(formula_str)
  
  fit <- lm(form, data = df)
  
  return(fit)
}

parsing_LM <- function(fit, gene, type, meta){
  
  s <- summary(fit)
  coefs <- s$coefficients
  
  R2 <- s$r.squared
  
  # --- Main effect: pooled slope + p-value across all cells ---
  main <- tryCatch({
    emt <- suppressMessages(
      emmeans::emtrends(fit, ~ 1, var = "avg_pseudotime", weights = "proportional")
    )
    summary(emt, infer = c(TRUE, TRUE))
  }, error = function(e) NULL)
  
  if (!is.null(main)) {
    main_slope <- main$avg_pseudotime.trend[1]
    main_p     <- main$p.value[1]
  } else {
    main_slope <- tryCatch(coefs["avg_pseudotime", "Estimate"], error = function(e) NA)
    main_p     <- tryCatch(coefs["avg_pseudotime", "Pr(>|t|)"], error = function(e) NA)
  }
  
  exp_cols <- list()
  
  if (length(unique(meta$exp)) > 1) {
    
    # --- Per-exp slope + p-value (tests each group's own slope vs 0) ---
    emt_g <- tryCatch(
      suppressMessages(
        emmeans::emtrends(fit, "exp", var = "avg_pseudotime")
      ),
      error = function(e) NULL
    )
    if (!is.null(emt_g)) {
      emt_df <- summary(emt_g, infer = c(TRUE, TRUE))
      for (i in seq_len(nrow(emt_df))) {
        curr_exp <- as.character(emt_df$exp[i])
        exp_cols[[paste0(curr_exp, "_slope")]] <- emt_df$avg_pseudotime.trend[i]
        exp_cols[[paste0(curr_exp, "_p")]]      <- emt_df$p.value[i]
      }
    }
    
    # --- Baseline (intercept) contrast vs reference exp ---
    for (curr_exp in levels(meta$exp)) {
      term <- paste0("exp", curr_exp)
      exp_cols[[paste0(curr_exp, "_contrast_p")]] <- tryCatch(
        coefs[term, "Pr(>|t|)"],
        error = function(e) NA
      )
    }
  }
  
  # --- Patient: overall effect across all patient levels ---
  if ("patient_id" %in% colnames(meta)) {
    exp_cols[["patient_p"]] <- tryCatch({
      fit_no_patient <- update(fit, . ~ . - patient_id)
      cmp <- anova(fit_no_patient, fit)
      cmp$`Pr(>F)`[2]
    }, error = function(e) NA)
  }
  
  metrics <- tibble(
    gene = gene,
    pseudotime = type,
    R2 = R2,
    main_p = main_p,
    main_slope = main_slope,
    !!!exp_cols
  )
  
  return(metrics)
}

run_LM <- function(binned_files, type, genes, threads=16, ref_exp=NULL){
  on.exit(plan(sequential), add = TRUE)
  binned_mat <- binned_files$binned_mat
  binned_meta <- binned_files$binned_meta
  
  if (length(unique(binned_meta$exp)) == 1){
    ref_exp=NULL
  }
  
  plan("multisession", workers = threads)
  
  gene_counts_list <- setNames(
    lapply(genes, function(g) binned_mat[g, ]),
    genes
  )
  
  metrics <- with_progress({
    p <- progressor(steps = length(genes))
    
    future_map2(genes, gene_counts_list, function(gene, count) {
      p()
      tryCatch({
        df <- binned_meta
        df$gene_counts <- count
        df$exp <- factor(df$exp)
        if ('patient_id' %in% colnames(df)) {
          df$patient_id <- factor(df$patient_id)
        }
        if (!is.null(ref_exp)){
          df$exp <- relevel(df$exp, ref = ref_exp)
        }
        fit <- fit_LM(df)
        parsing_LM(fit, gene, type, binned_meta)
      }, error = function(e) {
        tibble(gene = gene, error=conditionMessage(e))
      })
    }) %>%
      dplyr::bind_rows()
  })
  
  return(metrics)
}

default_palette_exp <- c(
  "#1f77b4", "#ff7f0e", "#2ca02c", "#d62728", "#9467bd",
  "#8c564b", "#e377c2", "#7f7f7f", "#bcbd22", "#17becf"
)

# patient_id: usually more levels -> a longer, distinct qualitative set
default_palette_patient <- c(
  "#66C2A5", "#FC8D62", "#8DA0CB", "#E78AC3", "#A6D854",
  "#FFD92F", "#E5C494", "#B3B3B3", "#1B9E77", "#D95F02",
  "#7570B3", "#E7298A", "#66A61E", "#E6AB02", "#A6761D",
  "#B15928", "#A6CEE3", "#1F78B4", "#B2DF8A", "#33A02C"
)

default_palettes <- list(
  exp        = default_palette_exp,
  patient_id = default_palette_patient
)

get_lm_predictions <- function(curr_gene, meta_binned, binned_mat, type) {
  df <- meta_binned
  df$gene_counts <- binned_mat[curr_gene, ]
  df$exp <- factor(df$exp)
  if ('patient_id' %in% colnames(df)) {
    df$patient_id <- factor(df$patient_id)
  }
  
  fit <- fit_LM(df)
  
  newdf <- expand.grid(
    avg_pseudotime = seq(min(df$avg_pseudotime),
                         max(df$avg_pseudotime),
                         length.out = 200),
    exp = levels(df$exp)
  )
  
  if ("patient_id" %in% colnames(df)) {
    # Pick one reference patient PER exp group (nested design-safe)
    ref_patients <- df |>
      dplyr::distinct(exp, patient_id) |>
      dplyr::group_by(exp) |>
      dplyr::slice(1) |>
      dplyr::ungroup()
    
    newdf <- newdf |>
      dplyr::left_join(ref_patients, by = "exp")
    
    newdf$patient_id <- factor(newdf$patient_id, levels = levels(df$patient_id))
  }
  
  newdf$pred <- predict(fit, newdata = newdf)
  
  newdf$gene <- curr_gene
  df$gene <- curr_gene
  
  list(obs = df, pred = newdf)
}

plot_gene <- function(gene, binned_files, model = "gam", patient_shape = FALSE, palette = NA, point_size=1.5, point_alpha=0.5) {
  binned_mat  <- binned_files$binned_mat
  binned_meta <- binned_files$binned_meta
  type <- binned_files$type
  
  # --- Get predictions depending on model type ---
  model <- match.arg(model, c("gam", "lm"))
  
  pred_out <- if (model == "gam") {
    get_gam_predictions(gene, binned_meta, binned_mat, type)
  } else {
    get_lm_predictions(gene, binned_meta, binned_mat, type)
  }
  
  newdf <- pred_out$pred
  df    <- pred_out$obs
  
  ymax <- max(df$gene_counts, na.rm = TRUE)
  bar_y    <- ymax * 1.02
  bar_h    <- ymax * 0.02
  label_y  <- ymax * 1.045
  
  # Phase definitions
  phase <- get_phase(type)
  phase_colors  <- phase$phase_colors
  phase_regions <- phase$phase_regions
  
  # --- Palette: only exp needs a color palette now ---
  if (identical(palette, NA)) {
    pal <- default_palettes[['exp']]
    levels_needed <- sort(unique(as.character(df[['exp']])))
    pal <- setNames(pal[seq_along(levels_needed)], levels_needed)
  } else {
    pal <- palette
  }
  
  # --- Shape palette for patient_id, if requested ---
  shape_vals <- NULL
  if (patient_shape && "patient_id" %in% colnames(df)) {
    df$patient_id <- factor(df$patient_id)
    n_patients <- nlevels(df$patient_id)
    # Cycle through a reasonable set of distinguishable shapes
    shape_pool <- c(16, 17, 15, 3, 7, 8, 1, 2, 0, 5, 6, 4)
    shape_vals <- setNames(
      rep(shape_pool, length.out = n_patients),
      levels(df$patient_id)
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
  
  p <- ggplot(df, aes(avg_pseudotime, gene_counts, color = exp)) +
    (if (patient_shape) {
      geom_point(alpha = point_alpha, size = point_size, aes(shape = patient_id))
    } else {
      geom_point(alpha = point_alpha, size = point_size)
    }) +
    geom_line(data = newdf,
              aes(avg_pseudotime, pred, color = exp),
              linewidth = 1) +
    scale_color_manual(values = pal) +
    (if (patient_shape) scale_shape_manual(values = shape_vals) else NULL) +
    
    # ── Phase color bars ──────────────────────────────────────────────
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
    
    coord_cartesian(clip = "off") +
    scale_y_continuous(expand = expansion(mult = c(0.05, 0.12))) +
    
    ggtitle(gene, subtitle = paste(type, "-", toupper(model))) +
    theme(plot.margin = margin(t = 20, r = 10, b = 30, l = 10))
  
  if (type == 'all') {
    p <- p +
      geom_vline(xintercept = 0, linetype = "dotted",
                 color = "black", linewidth = 1.5)
  }
  p
}


get_gam_predictions <- function(curr_gene, meta_binned, binned_mat, type) {
  df <- meta_binned
  df$gene_counts <- binned_mat[curr_gene, ]
  df$exp <- factor(df$exp)
  if ('patient_id' %in% colnames(df)) {
    df$patient_id <- factor(df$patient_id)
  }
  
  fit <- fit_GAM(df, type, family_function, k)
  
  # Predictions
  newdf <- expand.grid(
    avg_pseudotime = seq(min(df$avg_pseudotime),
                         max(df$avg_pseudotime),
                         length.out = 200),
    exp = levels(df$exp)
  )
  if ("patient_id" %in% names(fit$model)) {
    newdf$patient_id <- df$patient_id[1]
    newdf$patient_id <- factor(newdf$patient_id)
  }
  
  # Exclude the patient random-effect term so predictions reflect population-level fit
  exclude_terms <- if ("patient_id" %in% names(fit$model)) "s(patient_id)" else NULL
  
  newdf$pred <- predict(fit, newdata = newdf, exclude = exclude_terms)
  
  newdf$gene <- curr_gene
  df$gene <- curr_gene
  
  list(obs = df, pred = newdf)
}

plot_multi_genes <- function(top_genes, binned_files, type, model = "gam",
                             legend = TRUE, palette = NA, patient_shape = FALSE, 
                             point_size=1.5, point_alpha=0.5) {
  binned_mat  <- binned_files$binned_mat
  meta_binned <- binned_files$binned_meta
  
  model <- match.arg(model, c("gam", "lm"))
  
  all_data <- map(top_genes, function(gene) {
    if (model == "gam") {
      get_gam_predictions(gene, meta_binned, binned_mat, type)
    } else {
      get_lm_predictions(gene, meta_binned, binned_mat, type)
    }
  })
  
  obs_df  <- map_dfr(all_data, "obs")
  pred_df <- map_dfr(all_data, "pred")
  
  obs_df$gene  <- factor(obs_df$gene,  levels = top_genes)
  pred_df$gene <- factor(pred_df$gene, levels = top_genes)
  
  # ── Phase definitions ──────────────────────────────────────────────────────
  phase <- get_phase(type)
  phase_colors  <- phase$phase_colors
  phase_regions <- phase$phase_regions
  
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
  
  # ── Color palette (exp only — patient no longer uses color) ────────────────
  if (identical(palette, NA)) {
    pal <- default_palettes[['exp']]
    levels_needed <- sort(unique(as.character(obs_df[['exp']])))
    pal <- setNames(pal[seq_along(levels_needed)], levels_needed)
  } else {
    pal <- palette
  }
  
  # ── Shape palette for patient_id, if requested ─────────────────────────────
  shape_vals <- NULL
  if (patient_shape && "patient_id" %in% colnames(obs_df)) {
    obs_df$patient_id <- factor(obs_df$patient_id)
    n_patients <- nlevels(obs_df$patient_id)
    
    shape_pool <- c(16, 17, 15, 3, 7, 8, 1, 2, 0, 5, 6, 4)
    
    if (n_patients > length(shape_pool)) {
      warning(sprintf(
        "patient_shape: %d patients but only %d distinguishable shapes available — shapes will repeat and patients may be visually indistinguishable. Consider faceting by patient instead.",
        n_patients, length(shape_pool)
      ))
    }
    
    shape_vals <- setNames(
      rep(shape_pool, length.out = n_patients),
      levels(obs_df$patient_id)
    )
  }
  
  # ── Plot ─────────────────────────────────────────────────────────────────
  p <- ggplot() +
    (if (patient_shape) {
      geom_point(
        data = obs_df,
        aes(x = avg_pseudotime, y = gene_counts, color = exp, shape = patient_id),
        alpha = point_alpha, size = point_size
      )
    } else {
      geom_point(
        data = obs_df,
        aes(x = avg_pseudotime, y = gene_counts, color = exp),
        alpha = point_alpha, size = point_size
      )
    }) +
    geom_line(
      data = pred_df,
      aes(x = avg_pseudotime, y = pred, color = exp),
      linewidth = 1
    ) +
    scale_color_manual(values = pal) +
    (if (patient_shape) scale_shape_manual(values = shape_vals) else NULL) +
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
      fontface = "bold", size = 2, vjust = 0
    ) +
    facet_wrap(~gene, scales = "free_y") +
    coord_cartesian(clip = "off") +
    scale_y_continuous(expand = expansion(mult = c(0.05, 0.12))) +
    theme_minimal() +
    labs(x = "Average Pseudotime", y = "Expression", color = "Experiment", shape = "Patient") +
    theme(
      text = element_text(size = 8),
      strip.text   = element_text(size = 8),
      plot.margin  = margin(t = 20, r = 10, b = 10, l = 10)
    )
  
  if (!legend) {
    p <- p + theme(legend.position = "none")
  } else {
    p <- p + theme(
      legend.position = "right",
      legend.title = element_text(size = 10),
      legend.text = element_text(size = 9),
      legend.key.size = unit(0.5, "cm")
    )
  }
  
  p
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



plot_gene_cc_dorm <- function(gene, binned_files_cc, binned_files_dorm, legend=F, colour_by_patient=TRUE) {
  
  make_panel <- function(binned_files, show_title = TRUE, position = "top", legend=F, ymax) {
    binned_mat  <- binned_files$binned_mat
    binned_meta <- binned_files$binned_meta
    type        <- binned_files$type
    
    gam_pred <- get_gam_predictions(gene, binned_meta, binned_mat, type)
    newdf <- gam_pred$pred
    df <- gam_pred$obs
    
    # bar/label positions now based on the SHARED ymax
    bar_y    <- ymax * 1.02
    bar_h    <- ymax * 0.02
    label_y  <- ymax * 1.045
    
    phase <- get_phase(type)
    phase_colors <- phase$phase_colors
    phase_regions <- phase$phase_regions
    
    rect_df <- do.call(rbind, lapply(names(phase_regions), function(ph) {
      data.frame(
        xmin = phase_regions[[ph]][1],
        xmax = phase_regions[[ph]][2],
        ymin = bar_y,
        ymax = bar_y + bar_h,
        fill = phase_colors[ph],
        stringsAsFactors = FALSE
      )
    }))
    
    text_df <- do.call(rbind, lapply(names(phase_regions), function(ph) {
      data.frame(
        x = mean(phase_regions[[ph]]),
        y = label_y,
        label = ph,
        stringsAsFactors = FALSE
      )
    }))
    
    p <- ggplot(df, aes(avg_pseudotime, gene_counts, color = exp)) +
      (if (colour_by_patient) {
        geom_point(alpha = 0.4, aes(color = patient_id))
      } else {
        geom_point(alpha = 0.4)
      }) +
      geom_line(data = newdf, aes(avg_pseudotime, pred, color = exp), linewidth = 1) +
      geom_rect(
        data = rect_df,
        aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
        fill = rect_df$fill, color = NA, inherit.aes = FALSE
      ) +
      geom_text(
        data = text_df,
        aes(x = x, y = y, label = label),
        inherit.aes = FALSE, fontface = "bold", size = 3.5, vjust = 0
      ) +
      coord_cartesian(clip = "off", ylim = c(NA, label_y * 1.02)) +
      scale_y_continuous(limits = c(0, NA), expand = expansion(mult = c(0.05, 0))) +
      theme_minimal() 
    
    if (show_title) {
      p <- p + ggtitle(gene, subtitle = type)
    } else {
      p <- p + labs(title = NULL, subtitle = type)
    }
    
    if (position == "top") {
      p <- p + theme(plot.margin = margin(t = 20, r = 10, b = 5, l = 10))
    } else {
      p <- p + theme(plot.margin = margin(t = 5, r = 10, b = 30, l = 10))
    }
    
    if (!legend) {
      p <- p + theme(legend.position = "none")
    } else {
      p <- p + theme(
        legend.position = "right",
        legend.title = element_text(size = 10),
        legend.text = element_text(size = 9),
        legend.key.size = unit(0.5, "cm")
      )
    }
    
    p
  }
  
  if (colour_by_patient & ((!'patient_id' %in% colnames(binned_files_cc$binned_meta)) |  (!'patient_id' %in% colnames(binned_files_dorm$binned_meta)))) {
    print('WARNING: patient_id column not found in binned_files')
    colour_by_patient = FALSE
  }
  
  # --- compute shared ymax across BOTH datasets ---
  ymax_cc   <- max(binned_files_cc$binned_mat[gene, ],   na.rm = TRUE)
  ymax_dorm <- max(binned_files_dorm$binned_mat[gene, ], na.rm = TRUE)
  ymax_shared <- max(ymax_cc, ymax_dorm)
  
  p_cc   <- make_panel(binned_files_cc,   show_title = TRUE,  position = "top",    legend = legend, ymax = ymax_shared)
  p_dorm <- make_panel(binned_files_dorm, show_title = FALSE, position = "bottom", legend = legend, ymax = ymax_shared)
  
  patchwork::wrap_plots(p_cc, p_dorm, ncol = 1) +
    patchwork::plot_layout(guides = "collect")
}

get_phase <- function(type) {
  if (type == 'dormancy') {
    phase_colors <- c(Light = 'lightgrey', Mid = 'darkgrey', Deep = 'black')
    phase_regions <- list(Light = c(-0.4, 0), Mid = c(-0.6, -0.4), Deep = c(-1, -0.6))
  } else if (type == 'cell_cycle') {
    phase_colors <- c(G1 = '#1f77b4', S = '#ff7f0e', G2M = '#2ca02c')
    phase_regions <- list(G1 = c(0, 0.4), S = c(0.4, 0.75), G2M = c(0.75, 1))
  } else if (type == 'all') {
    phase_colors  <- c(Light = "lightgrey", Mid = "darkgrey", Deep = "black", G1 = "#1f77b4", S = "#ff7f0e", G2M = "#2ca02c")
    phase_regions <- list(Light = c(-0.4, 0), Mid = c(-0.6, -0.4), Deep = c(-1, -0.6), G1 = c(0, 0.4), S = c(0.4, 0.75), G2M = c(0.75, 1))
  }
  return(list(phase_colors=phase_colors, phase_regions=phase_regions))
}


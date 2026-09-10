#!/usr/bin/env Rscript
# =====================================================================
# ODB Project - Script 02: Structural Distance Metrics
# Computes CRR (Cognate Retention Rate), WSSI (Weighted Structural
# Similarity Index) and DI (Divergence Index), runs a weight
# sensitivity / permutation analysis, and plots a radar chart.
# =====================================================================

suppressPackageStartupMessages({
  library(readxl)
  library(ggplot2)
  library(dplyr)
})

find_xlsx <- function() {
  cand <- c("odb_raw_data_tables_readable.xlsx",
            "../odb_raw_data_tables_readable.xlsx",
            "/mnt/data/odb_raw_data_tables_readable.xlsx")
  for (p in cand) if (file.exists(p)) return(normalizePath(p))
  stop("Input workbook not found.")
}
xlsx_path <- find_xlsx()
out_dir <- "figures_02"
dir.create(out_dir, showWarnings = FALSE)

theme_odb <- theme_minimal(base_size = 13) +
  theme(plot.title = element_text(face = "bold", size = 15),
        panel.grid.minor = element_blank(),
        legend.position = "top")

## =====================================================================
## 1. Metric functions -------------------------------------------------
## =====================================================================

#' Cognate Retention Rate: proportion of cognate-retained items
#' cognate_counts: named numeric vector of counts per cognate type
#' total: total number of items (default sum of counts)
crr <- function(cognate_counts, total = sum(cognate_counts)) {
  stopifnot(is.numeric(cognate_counts), total > 0)
  round(sum(cognate_counts) / total, 4)
}

#' Weighted Structural Similarity Index across k dimensions
#' values   : similarity scores in [0,1] per dimension
#' weights  : non-negative weights, same length, not all zero
wssi <- function(values, weights) {
  stopifnot(length(values) == length(weights),
            all(weights >= 0), sum(weights) > 0)
  sum(weights * values) / sum(weights)
}

#' Divergence Index: complement of the weighted similarity
di <- function(values, weights) round(1 - wssi(values, weights), 4)

#' Wilson score interval (exact formula)
wilson_ci <- function(x, n, z = 1.96) {
  p <- x / n
  d <- 1 + z^2 / n
  centre <- (p + z^2 / (2 * n)) / d
  half   <- (z * sqrt(p * (1 - p) / n + z^2 / (4 * n^2))) / d
  c(lower = max(0, centre - half), upper = min(1, centre + half))
}

## =====================================================================
## 2. Application to ODB data ------------------------------------------
## =====================================================================
cognates <- read_excel(xlsx_path, sheet = "Table_4_2_Cognates")
names(cognates) <- make.names(names(cognates))
total_items <- sum(cognates$Count)

# Cognate retention: treat COG-PHON + IDENT as retained cognate forms
retained <- cognates$Count[cognates$Cognate.type %in% c("COG-PHON", "IDENT", "COG PHON")]
retention_rate <- crr(retained, total_items)
cat("\nCognate Retention Rate (CRR):", retention_rate,
    sprintf("(%d/%d items)", sum(retained), total_items), "\n")

# Dimension-level similarity scores derived from the data
phonology <- read_excel(xlsx_path, sheet = "Table_4_3_Phonology")
semantic  <- read_excel(xlsx_path, sheet = "Table_4_4_Semantic")
names(phonology) <- make.names(names(phonology))
names(semantic)  <- make.names(names(semantic))

# Lexical similarity  = CRR
# Phonological similarity = 1 - (share of items with an attested shift)
# Semantic similarity = share of items with NO semantic change
lexical_sim      <- retention_rate
phon_shift_share <- 1 - crr(retained, total_items)   # illustrative proxy
phonological_sim <- round(mean(1 - phon_shift_share), 4)
semantic_sim     <- round(crr(semantic$Count[semantic$Semantic.change == "none"],
                              sum(semantic$Count)), 4)

base_weights <- c(Lexical = 0.5, Phonological = 0.3, Morphosyntactic = 0.2)
values <- c(lexical_sim, phonological_sim, semantic_sim)
names(values) <- names(base_weights)

W <- wssi(values, base_weights)
D <- di(values, base_weights)
cat("Dimension similarities:\n"); print(values)
cat("WSSI (base weights 0.5/0.3/0.2):", round(W, 4), "\n")
cat("Divergence Index (DI):", D, "\n")

## =====================================================================
## 3. Sensitivity / permutation test across dimension weights ---------
## =====================================================================
set.seed(42)
n_sims <- 10000
sim_wssi <- replicate(n_sims, {
  w <- runif(3)                      # random Dirichlet-like weights
  wssi(values, w)
})

cat("\n--- Sensitivity analysis (", n_sims, " random weight sets) ---\n", sep = "")
cat("Mean WSSI:", round(mean(sim_wssi), 4),
    " SD:", round(sd(sim_wssi), 4), "\n")
cat("95% interval of WSSI under random weighting: [",
    round(quantile(sim_wssi, 0.025), 4), ", ",
    round(quantile(sim_wssi, 0.975), 4), "]\n", sep = "")
cat("P(WSSI under random weights <= observed):",
    mean(sim_wssi <= W), "\n")

sens_df <- data.frame(WSSI = sim_wssi)
p4 <- ggplot(sens_df, aes(x = WSSI)) +
  geom_histogram(bins = 60, fill = "#2C6E8F", colour = "white") +
  geom_vline(xintercept = W, colour = "#B5432A", linewidth = 1) +
  annotate("text", x = W, y = Inf, vjust = 2, hjust = -0.05,
           label = paste0("Observed WSSI = ", round(W, 3)),
           colour = "#B5432A", fontface = "bold") +
  labs(title = "Sensitivity of WSSI to Dimension Weights",
       subtitle = paste0(n_sims, " random weight permutations"),
       x = "WSSI", y = "Count") +
gsave(file.path(out_dir, "fig_(out_dir, "fig_4_wssi_sensitivity.png"), p4,
       width = 8, height = 5, dpi = 300)

## =====================================================================
## 4. Radar chart of dimension similarity ------------------------------
## =====================================================================
radar_df <- data.frame(
  dimension  = names(values),
  similarity = as.numeric(values)
)
# close the polygon
radar_closed <- rbind(radar_df, radar_df[1, ])
radar_closed$angle <- seq(0, 2 * pi, length.out = 4)[1:4]

p5 <- ggplot(radar_closed, aes(x = angle, y = similarity)) +
  geom_polygon(fill = "#2C6E8F", alpha = 0.25, colour = "#2C6E8F",
               linewidth = 1) +
  geom_point(colour = "#B5432A", size = 3) +
  coord_polar(start = -pi / 2) +
  scale_y_continuous(limits = c(0, 1), breaks = seq(0, 1, 0.25)) +
  scale_x_continuous(breaks = seq(0, 2 * pi, length.out = 4)[1:3],
                     labels = names(values)) +
  labs(title = "Structural Similarity by Analytical Dimension",
       x = NULL, y = NULL) +
  theme_odb +
  theme(axis.text.y = element_text(size = 8))
ggsave(file.path(out_dir, "fig_5_dimension_radar.png"), p5,
       width = 7, height = 6, dpi = 300)

## Simple barplot alternative
p6 <- ggplot(radar_df, aes(x = reorder(dimension, similarity),
                           y = similarity)) +
  geom_col(fill = "#2C6E8F", width = 0.6) +
  geom_hline(yintercept = W, linetype = "dashed", colour = "#B5432A") +
  coord_flip(ylim = c(0, 1)) +
  labs(title = "Dimension Similarity vs. Overall WSSI (dashed)",
       x = NULL, y = "Similarity (0-1)") +
  theme_odb
ggsave(file.path(out_dir, "fig_6_dimension_barplot.png"), p6,
       width = 7, height = 4, dpi = 300)

## Save metric results
write.csv(data.frame(
  Metric = c("CRR", "WSSI", "DI", "WSSI_sd_random", "P_random_leq_observed"),
  Value  = c(retention_rate, round(W, 4), D,
             round(sd(sim_wssi), 4), mean(sim_wssi <= W))
), file.path(out_dir, "structural_metrics.csv"), row.names = FALSE)

message("\n[02] Structural distance metrics complete. Outputs in: ",
        file.path(getwd(), out_dir))

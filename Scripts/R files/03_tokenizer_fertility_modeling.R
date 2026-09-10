#!/usr/bin/env Rscript
# =====================================================================
# ODB Project - Script 03: Tokenizer Fertility Modeling
# Simulates subword fertility ratios (tokens per word) for
# Azerbaijani (Az) vs Turkish (Tr), models their distributions,
# plots token inflation, and tests the asymmetry with paired tests.
# =====================================================================

suppressPackageStartupMessages({
  library(ggplot2)
  library(dplyr)
})

set.seed(2024)
out_dir <- "figures_03"
dir.create(out_dir, showWarnings = FALSE)

theme_odb <- theme_minimal(base_size = 13) +
  theme(plot.title = element_text(face = "bold", size = 15),
        plot.subtitle = element_text(colour = "grey35"),
        panel.grid.minor = element_blank(),
        legend.position = "top")

## =====================================================================
## 1. Simulation of fertility ratios -----------------------------------
## =====================================================================
## Calibrated to typical multilingual-BERT-style behaviour:
## Turkish morphological transparency -> fertility ~1.6-2.2
## Azerbaijani under-representation   -> fertility ~2.0-2.9
n_items <- 500

az_fert <- rgamma(n_items, shape = 12, rate = 12 / 2.45)  # mean ~2.45
tr_fert <- rgamma(n_items, shape = 18, rate = 18 / 1.85)  # mean ~1.85

tok_df <- data.frame(
  item_id  = 1:n_items,
  az_fert  = az_fert,
  tr_fert  = tr_fert
)
tok_df$token_inflation <- tok_df$az_fert - tok_df$tr_fert

long_df <- tok_df %>%
  select(item_id, az_fert, tr_fert) %>%
  tidyr::pivot_longer(cols = c(az_fert, tr_fert),
                      names_to = "Language", values_to = "fertility") %>%
  mutate(Language = factor(Language,
                           levels = c("tr_fert", "az_fert"),
                           labels = c("Turkish", "Azerbaijani")))

## =====================================================================
## 2. Distribution modeling --------------------------------------------
## =====================================================================
cat("=== Fertility ratio distributions (simulated) ===\n")
cat("Azerbaijani: mean =", round(mean(az_fert), 3),
    " sd =", round(sd(az_fert), 3), "\n")
cat("Turkish    : mean =", round(mean(tr_fert), 3),
    " sd =", round(sd(tr_fert), 3), "\n")
cat("Mean token inflation (Az - Tr):",
    round(mean(tok_df$token_inflation), 3), "\n\n")

## Gamma MLE fit per language (fitdistr from MASS, or method of moments)
fit_gamma <- function(x) {
  m <- mean(x); v <- var(x)
  shape <- m^2 / v; rate <- m / v
  data.frame(shape = shape, rate = rate, mean = m, variance = v)
}
cat("Gamma MLE / MoM fits:\n")
print(rbind(Azerbaijani = fit_gamma(az_fert), Turkish = fit_gamma(tr_fert)))

## KS test against fitted gamma
ks_az <- suppressWarnings(ks.test(az_fert, "pgamma",
                                  shape = fit_gamma(az_fert)$shape,
                                  rate  = fit_gamma(az_fert)$rate))
ks_tr <- suppressWarnings(ks.test(tr_fert, "pgamma",
                                  shape = fit_gamma(tr_fert)$shape,
                                  rate  = fit_gamma(tr_fert)$rate))
cat("\nKS goodness-of-fit (Azerbaijani): D =", round(ks_az$statistic, 4),
    " p =", format.pval(ks_az$p.value), "\n")
cat("KS goodness-of-fit (Turkish-of-fit (Turkish(ks_tr$statistic, 4),
    " p =", format.pval(ks_tr$p.value), "\n")

## =====================================================================
## 3. Paired tests of token length asymmetry ---------------------------
## =====================================================================
wt <- wilcox.test(tok_df$az_fert, tok_df$tr_fert, paired = TRUE,
                  alternative = "greater")
tt <- t.test(tok_df$az_fert, tok_df$tr_fert, paired = TRUE,
             alternative = "greater")

cat("\n=== Wilcoxon signed-rank test (Az > Tr, paired) ===\n")
print(wt)
cat("\n=== Paired t-test (Az > Tr, paired) ===\n")
print(tt)

# Effect size: Cohen's d for paired samples
d_cohen <- mean(tok_df$token_inflation) / sd(tok_df$token_inflation)
cat("\nCohen's d (paired):", round(d_cohen, 3), "\n")

## =====================================================================
## 4. Visuals ------------------------------------------------------------
## =====================================================================
## 4a. Density plots
p7 <- ggplot(long_df, aes(x = fertility, fill = Language)) +
  geom_density(alpha = 0.55, colour = NA) +
  geom_vline(data = long_df %>% group_by(Language) %>%
               summarise(m = mean(fertility)),
             aes(xintercept = m, colour = Language),
             linetype = "dashed", linewidth = 0.9) +
  scale_fill_manual(values = c("Azerbaijani" = "#B5432A",
                               "Turkish" = "#2C6E8F")) +
  scale_colour_manual(values = c("Azerbaijani" = "#B5432A",
                                 "Turkish" = "#2C6E8F")) +
  labs(title = "Subword Fertility Ratio Distributions",
       subtitle = "Tokens per word: Azerbaijani vs Turkish (simulated)",
       x = "Fertility ratio (tokens / word)", y = "Density",
       fill = NULL, colour = NULL) +
  theme_odb
ggsave(file.path(out_dir, "fig_7_fertility_density.png"), p7,
       width = 8, height = 5, dpi = 300)

## 4b. Boxplot of fertility by language
p8 <- ggplot(long_df, aes(x = Language, y = fertility, fill = Language)) +
  geom_boxplot(width = 0.45, alpha = 0.8, outlier.size = 0.7) +
  geom_jitter(width = 0.08, alpha = 0.15, size = 0.6) +
  scale_fill_manual(values = c("Azerbaijani" = "#B5432A",
                               "Turkish" = "#2C6E8F")) +
  labs(title = "Token Fertility by Language",
       subtitle = paste0("Wilcoxon signed-rank p ",
                         format.pval(wt$p.value), "; Cohen's d = ",
                         round(d_cohen, 2)),
       x = NULL, y = "Tokens per word") +
  theme_odb + theme(legend.position = "none")
ggsave(file.path(out_dir, "fig_8_fertility_boxplot.png"), p8,
       width = 6.5, height = 5, dpi = 300)

## 4c. Token inflation (paired difference)
p9 <- ggplot(tok_df, aes(x = token_inflation)) +
  geom_histogram(aes(y = after_stat(density)), bins = 40,
                 fill = "#2C6E8F", colour = "white") +
  geom_density(colour = "#B5432A", linewidth = 1) +
  geom_vline(xintercept = 0, linetype = "dashed") +
  labs(title = "Distribution of Token Inflation (Az - Tr)",
       subtitle = paste0("Mean inflation = ",
                         round(mean(tok_df$token_inflation), 3),
                         " extra tokens per word"),
       x = "Token inflation (Az fertility - Tr fertility)", y = "Density") +
  theme_odb
ggsave(file.path(out_dir, "fig_9_token_inflation.png"), p9,
       width = 8, height = 5, dpi = 300)

## Save results table
write.csv(data.frame(
  metric = c("mean_az_fertility", "mean_tr_fertility", "mean_inflation",
             "wilcoxon_p", "paired_t_p", "cohens_d"),
  value  = c(mean(az_fert), mean(tr_fert), mean(tok_df$token_inflation),
             wt$p.value, tt$p.value, d_cohen)
), file.path(out_dir, "fertility_test_results.csv"), row.names = FALSE)

message("\n[03] Tokenizer fertility modeling complete. Outputs in: ",
        file.path(getwd(), out_dir))

#!/usr/bin/env Rscript
# ============================================================
# 04_llm_generative_erasure_audit.R
# ODB pipeline step 4: audit of LLM / MT generative erasure
# Reads LLM_Evaluation_Results.csv, recomputes Wilson score CIs,
# chi-square / Fisher tests, and produces a Forest plot (PNG).
# ============================================================

suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
})

DATA_DIR <- file.path(dirname(dirname(normalizePath(sub("^--file=.*", "",
  grep("^--file=", commandArgs(FALSE), value = TRUE)[1], mustWork = FALSE)))), "ODB_data_csvs")
if (!dir.exists(DATA_DIR)) DATA_DIR <- normalizePath("../ODB_data_csvs")
OUT_DIR  <- "../figures"
dir.create(OUT_DIR, showWarnings = FALSE, recursive = TRUE)

csv_path <- file.path(DATA_DIR, "LLM_Evaluation_Results.csv")
if (!file.exists(csv_path)) stop("Missing input file: ", csv_path)
dat <- read.csv(csv_path, stringsAsFactors = FALSE)

# ---- Parse percent columns -------------------------------------------------
pct <- function(x) as.numeric(sub("%", "", trimws(x))) / 100
parse_ci <- function(x) {
  nums <- regmatches(x, gregexpr("[0-9]+\\.[0-9]+", x))[[1]]
  as.numeric(nums) / 100
}
dat$error <- pct(dat$Overall.Error..)
dat$ci_lo <- sapply(dat$X95..Wilson.CI, function(z) parse_ci(z)[1])
dat$ci_hi <- sapply(dat$X95..Wilson.CI, function(z) parse_ci(z)[2])
# Wilson assumes n ~ 200 evaluated items per system (documented assumption)
N <- 200
dat$n_success <- round(dat$error * N)
dat$wilson_lo <- mapply(function(k, n) {
  p <- k / n; z <- 1.96
  (p + z^2/(2*n) - z*sqrt(p*(1-p)/n + z^2/(4*n^2))) / (1 + z^2/n)
}, dat$n_success, N)
dat$wilson_hi <- mapply(function(k, n) {
  p <- k / n; z <- 1.96
  (p + z^2/(2*n) + z*sqrt(p*(1-p)/n + z^2/(4*n^2))) / (1 + z^2/n)
}, dat$n_success, N)

# ---- Inferential tests -----------------------------------------------------
tests <- lapply(seq_len(nrow(dat)), function(i) {
  tab <- matrix(c(dat$n_success[i], N - dat$n_success[i],
                  40, N - 40), nrow = 2)  # 20% GS baseline
  chi <- suppressWarnings(chisq.test(tab))
  fis <- tryCatch(fisher.test(tab)$p.value, error = function(e) NA)
  data.frame(Model = dat$Model[i],
             chi_square = round(unname(chi$statistic), 2),
             chi_p = chi$p.value,
             fisher_p = fis)
})
tests <- do.call(rbind, tests)
write.csv(tests, file.path(OUT_DIR, "04_llm_erasure_tests.csv"), row.names = FALSE)

# ---- Forest plot -----------------------------------------------------------
p <- ggplot(dat, aes(x = error * 100, y = reorder(Model, -error))) +
  geom_point(size = 3, shape = 18, color = "darkred") +
  geom_errorbarh(aes(xmin = ci_lo * 100, xmax = ci_hi * 100), height = 0.2) +
  geom_vline(xintercept = 20, linetype = "dashed", color = "grey40") +
  labs(title = "Generative Erasure Audit: Error Rates with 95% Wilson CI",
       subtitle = sprintf("Dashed line = gold-standard baseline (20%%); N = %d items per system", N),
       x = "Error rate (%)", y = NULL) +
  theme_minimal(base_size = 12)
ggsave(file.path(OUT_DIR, "04_forest_plot_error_rates.png"), p,
       width = 8, height = 4, dpi = 300)

cat("04_llm_generative_erasure_audit.R completed.\n")
print(dat[, c("Model", "error", "wilson_lo", "wilson_hi")])
print(tests)

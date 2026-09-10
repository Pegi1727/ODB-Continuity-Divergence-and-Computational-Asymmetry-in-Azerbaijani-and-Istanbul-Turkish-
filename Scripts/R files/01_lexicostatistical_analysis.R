#!/usr/bin/env Rscript
# =====================================================================
# ODB Project - Script 01: Lexicostatistical Analysis
# Loads Table 4.2 (Cognates), 4.3 (Phonology), 4.4 (Semantic) from
# odb_raw_data_tables_readable.xlsx and produces publication-ready
# ggplot2 visuals, summary statistics and frequency tables.
# =====================================================================

suppressPackageStartupMessages({
  library(readxl)
  library(ggplot2)
})

## ---- 0. Paths -------------------------------------------------------
find_xlsx <- function() {
  cand <- c("odb_raw_data_tables_readable.xlsx",
            "../odb_raw_data_tables_readable.xlsx",
            "/mnt/data/odb_raw_data_tables_readable.xlsx")
  for (p in cand) if (file.exists(p)) return(normalizePath(p))
  stop("Input workbook 'odb_raw_data_tables_readable.xlsx' not found.")
}
xlsx_path <- find_xlsx()
out_dir <- "figures_01"
dir.create(out_dir, showWarnings = FALSE)

## Publication theme ----------------------------------------------------
theme_odb <- theme_minimal(base_size = 13) +
  theme(
    plot.title       = element_text(face = "bold", size = 15),
    plot.subtitle    = element_text(colour = "grey35"),
    panel.grid.minor = element_blank(),
    legend.position  = "top"
  )

## ---- 1. Load sheets --------------------------------------------------
cognates  <- read_excel(xlsx_path, sheet = "Table_4_2_Cognates")
phonology <- read_excel(xlsx_path, sheet = "Table_4_3_Phonology")
semantic  <- read_excel(xlsx_path, sheet = "Table_4_4_Semantic")

names(cognates)  <- make.names(names(cognates))
names(phonology) <- make.names(names(phonology))
names(semantic)  <- make.names(names(semantic))

cat("\n=== Table 4.2 Cognates ===\n"); print(cognates)
cat("\n=== Table 4.3 Phonology ===\n"); print(phonology)
cat("\n=== Table 4.4 Semantic ===\n"); print(semantic)

## ---- 2. Summary statistics ------------------------------------------
cat("\n--- Summary statistics: cognate counts ---\n")
print(summary(cognates$Count))
cat("Total cognate items:", sum(cognates$Count), "\n")
cat("Herfindahl-type concentration of cognate types:",
    round(sum((cognates$Percentage / 100)^2), 4), "\n")

cat("\n--- Frequency table: phonological shifts ---\n")
print(as.data.frame(phonology))

cat("\n--- Frequency table: semantic change ---\n")
print(as.data.frame(semantic))

## ---- 3. Figures ------------------------------------------------------
## 3a. Cognate-type distribution
p1 <- ggplot(cognates, aes(x = reorder(Cognate.type, Count), y = Count)) +
  geom_col(fill = "#2C6E8F", width = 0.65, alpha = 0.9) +
  geom_text(aes(label = paste0(sprintf("%.1f", Percentage), "%")),
            hjust = -0.15, size = 4) +
  coord_flip(clip = "off") +
  scale_y_continuous(expand = expansion(mult = c(0, 0.15))) +
  labs(
    title    = "Distribution of Cognate Types (Azerbaijani vs. Turkish)",
    subtitle = paste0("N = ", sum(cognates$Count), " lexical items (Table 4.2)"),
    x = "Cognate type", y = "Count"
  ) +
  theme_odb
ggsave(file.path(out_dir, "fig_1_cognate_distribution.png"), p1,
       width = 8, height = 5, dpi = 300)

## 3b. Phonological shift bar chart
p2 <- ggplot(phonology, aes(x = reorder(Phonological.shift, Count), y = Count)) +
  geom_col(fill = "#B5432A", width = 0.7) +
  geom_text(aes(label = Count), hjust = -0.3, size = 4) +
  coord_flip(clip = "off") +
  scale_y_continuous(expand = expansion(mult = c(0, 0.15))) +
  labs(
    title    = "Frequency of Phonological Correspondence Patterns",
    subtitle = "Shared phonological shifts between Azerbaijani and Turkish (Table 4.3)",
    x = NULL, y = "Frequency"
  ) +
  theme_odb
ggsave(file.path(out_dir, "fig_2_phonological_shifts.png"), p2,
       width = 8, height = 5.5, dpi = 300)

## 3c. Semantic change donut
p3 <- ggplot(semantic, aes(x = 2, y = Percentage, fill = Semantic.change)) +
  geom_col(width = 1, colour = "white") +
  coord_polar(theta = "y") +
  xlim +
  xlim5, 2.5) +
  geom_text(aes(label = paste0(sprintf("%.1f", Percentage), "%")),
            position = position_stack(vjust = 0.5), colour = "white", size = 4) +
  scale_fill_brewer(palette = "Set2") +
  labs(title = "Semantic Change Profile", fill = NULL, x = NULL, y = NULL) +
  theme_minimal(base_size = 13) +
  theme(legend.position = "right")
ggsave(file.path(out_dir, "fig_3_semantic_change_donut.png"), p3,
       width = 7, height = 5, dpi = 300)

message("\n[01] Lexicostatistical analysis complete. Figures in: ",
        file.path(getwd(), out_dir))

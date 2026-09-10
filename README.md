# ODB-Continuity-Divergence-and-Computational-Asymmetry-in-Azerbaijani-and-Istanbul-Turkish-
A multidimensional framework for analyzing linguistic continuity, structural distance, and computational asymmetry between Azerbaijani and Istanbul Turkish. The Oghuz Divergence Benchmark (ODB) integrates lexical, phonological, morphological, semantic, tokenizer, and LLM-based analyses.
# ODB-Azerbaijani-Turkish: Linguistic Continuity and Computational Asymmetry

[![Python 3.10+](https://img.shields.io/badge/python-3.10+-blue.svg)](https://www.python.org/downloads/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![DOI](https://img.shields.io/badge/DOI-10.5281%2Fzenodo.xxxxxxx-blue)](https://zenodo.org/)
[![Reproducibility](https://img.shields.io/badge/reproducibility-verified-brightgreen.svg)](docs/reproducibility.md)

This repository hosts the official codebase, processed datasets, and empirical replication pipelines for the research paper:

> **"Between Continuity and Divergence: A Multidimensional Analysis of Structural Distance and Computational Asymmetry in North Azerbaijani and Istanbul Turkish"**

The project introduces the **Oghuz Divergence Paradigm (ODB)**, combining classical comparative lexicostatistics (Swadesh 207 list) with modern subword tokenizer audits and Large Language Model (LLM) generative erasure evaluations.

---

## 🔬 Key Empirical Findings

1. **High Genetic Retention:** Cognate Retention Rate ($CRR$) of **85.99%** demonstrates profound morphological and lexical continuity between North Azerbaijani and Istanbul Turkish.
2. **Structural Distance Measures:** Weighted Structural Similarity Index ($WSSI = 0.680$) and Divergence Index ($DI = 0.495$).
3. **Tokenizer Asymmetry:** Subword tokenizers exhibit an average Azerbaijani-to-Turkish Fertility Ratio of **1.45**, demonstrating systematic computational penalty.
4. **Generative Erasure in LLMs:** Frontier models show pervasive replacement of Azerbaijani morphology with Turkish standard forms (Error rates: GPT-4o **52.1%**, Gemini 1.5 **48.7%**, Llama-3 **58.2%**, Google Translate **69.3%**).

---

## 📂 Repository Structure
```text
ODB-Azerbaijani-Turkish/
├── data/
│   ├── processed/odb_lexical_dataset.csv     # Coded 207-item Swadesh dataset
│   └── metadata/data_dictionary.csv           # Feature definitions & schema
├── src/                                       # Core analytical modules
│   ├── crR_wssi_di.py                         # Formula implementations for CRR, WSSI, DI
│   ├── lexical_coding.py                      # Lexical categorization & stats
│   ├── phonological_analysis.py               # Sound shift distribution
│   ├── morphological_analysis.py              # Structural parity metrics
│   ├── tokenizer_analysis.py                  # Fertility ratio computations
│   └── generative_substitution.py             # LLM/MT audit & Wilson CI
├── analysis/                                  # Executable replication scripts (01-06)
├── notebooks/                                 # Interactive Jupyter exploration
├── results/                                   # Empirical tables (CSVs) and figures
├── docs/                                      # Framework documentation & protocols
🚀 Quick Start

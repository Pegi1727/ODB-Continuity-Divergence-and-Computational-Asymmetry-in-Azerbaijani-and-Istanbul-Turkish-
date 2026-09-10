"""
ODB Project — Script 04: LLM Generative Erasure Evaluation
==========================================================
Analyses the ODB LLM evaluation results (model error rates for Azerbaijani
generative prompts, overall and under semantic-equivalence matching, with
Wilson CIs and significance against the gold-standard baseline) and
visualises the "generative erasure" profile of each model.

Outputs
-------
    /mnt/data/figures/figure_4_4_llm_generative_erasure.png
    /mnt/data/figures/summary_4_4_llm_generative_erasure.csv

Author: ODB project pipeline (Python port of 04_llm_generative_erasure.R)
"""
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

DATA_DIR = Path("/mnt/data/ODB_data_csvs")
FIG_DIR = Path("/mnt/data/figures")
FIG_DIR.mkdir(parents=True, exist_ok=True)
OUT_FIG = FIG_DIR / "figure_4_4_llm_generative_erasure.png"
OUT_CSV = FIG_DIR / "summary_4_4_llm_generative_erasure.csv"


def load_llm() -> pd.DataFrame:
    df = pd.read_csv(DATA_DIR / "LLM_Evaluation_Results.csv")
    df.columns = [c.strip() for c in df.columns]

    def pct(col):
        return df[col].str.rstrip("%").astype(float) / 100

    def ci(col):
        lo, hi = df[col].str.strip("[]").str.split(",", expand=True)
        return pct_col(lo), pct_col(hi)

    def pct_col(s):
        return s.str.rstrip("% ").astype(float) / 100

    df["err"] = pct("Overall Error %")
    df["err_lo"], df["err_hi"] = ci("95% Wilson CI")
    df["sem_err"] = pct("SEM Error %")
    df["sem_lo"], df["sem_hi"] = ci("SEM CI [L, U]")
    df["p_label"] = df["p-value (vs. GS)"].str.extract(r"(p\s*<\s*0\.0+1?|p\s*>=?\s*0\.05)")[0]
    return df


def main() -> None:
    df = load_llm()

    summary = pd.DataFrame({
        "Model": df["Model"],
        "Overall error": df["err"],
        "Overall CI low": df["err_lo"],
        "Overall CI high": df["err_hi"],
        "SEM error": df["sem_err"],
        "SEM CI low": df["sem_lo"],
        "SEM CI high": df["sem_hi"],
        "SEM uplift (pp)": (df["sem_err"] - df["err"]) * 100,
        "p vs GS": df["p-value (vs. GS)"],
    })
    summary.to_csv(OUT_CSV, index=False)

    x = np.arange(len(df))
    w = 0.36

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    # --- Panel A: error rates with Wilson / SEM CIs -----------------------
    ax1.bar(x - w / 2, df["err"] * 100, w, yerr=[(df["err"] - df["err_lo"]) * 100,
                                                 (df["err_hi"] - df["err"]) * 100],
            capsize=4, color="#d1495b", edgecolor="black", label="Overall error")
    ax1.bar(x + w / 2, df["sem_err"] * 100, w, yerr=[(df["sem_err"] - df["sem_lo"]) * 100,
                                                     (df["sem_hi"] - df["sem_err"]) * 100],
            capsize=4, color="#2e6f95", edgecolor="black", label="SEM-matched error")
    for i, (e, s) in enumerate(zip(df["err"], df["sem_err"])):
        ax1.text(i - w / 2, e * 100 + 1.2, f"{e*100:.1f}", ha="center", fontsize=9)
        ax1.text(i + w / 2, s * 100 + 1.2, f"{s*100:.1f}", ha="center", fontsize=9)
    ax1.set_xticks(x, df["Model"])
    ax1.set_ylabel("Error rate (%)")
    ax1.set_ylim(0, 100)
    ax1.set_title("A. Generative error rates (95% CIs)")
    ax1.legend(frameon=False)
    ax1.spines[["top", "right"]].set_visible(False)

    # --- Panel B: SEM uplift over overall error ---------------------------
    uplift = (df["sem_err"] - df["err"]) * 100
    ax2.bar(x, uplift, 0.55, color="#f4a261", edgecolor="black")
    for i, v in enumerate(uplift):
        ax2.text(i, v + 0.4, f"+{v:.1f}", ha="center", fontweight="bold")
    ax2.set_xticks(x, df["Model"])
    ax2.set_ylabel("SEM − Overall (percentage points)")
    ax2.set_title("B. Erasure uplift under semantic equivalence")
    ax2.spines[["top", "right"]].set_visible(False)

    fig.suptitle("Figure 4.4 — LLM generative erasure of Azerbaijani (ODB evaluation)",
                 fontweight="bold")
    fig.tight_layout(rect=[0, 0, 1, 0.93])
    fig.savefig(OUT_FIG, dpi=200)
    plt.close(fig)

    print(summary.round(3).to_string(index=False))
    print(f"Saved: {OUT_FIG}\nSaved: {OUT_CSV}")


if __name__ == "__main__":
    main()

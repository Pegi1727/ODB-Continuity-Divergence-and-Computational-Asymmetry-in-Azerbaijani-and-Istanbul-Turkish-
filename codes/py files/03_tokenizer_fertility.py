"""
ODB Project — Script 03: Tokenizer Fertility Analysis
=====================================================
Compares the tokenization "fertility" (tokens required per word / characters
per token) of Azerbaijani orthographic forms versus Turkish reference forms
from the Appendix F sample, and links the resulting length asymmetry to the
LLM error rates reported in the ODB evaluation sheet.

Fertility proxy (no live tokenizer in the sandbox):
    - char-length ratio        r_len = len(az) / len(tr)
    - inverse fertility index  IFI   = 1 / r_len   (>1 means Azerbaijani
      forms are shorter/denser; <1 means they are longer and therefore
      fragment into more subword tokens for a Turkish-oriented tokenizer)

Outputs
-------
    /mnt/data/figures/figure_4_3_tokenizer_fertility.png
    /mnt/data/figures/summary_4_3_tokenizer_fertility.csv

Author: ODB project pipeline (Python port of 03_tokenizer_fertility.R)
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
OUT_FIG = FIG_DIR / "figure_4_3_tokenizer_fertility.png"
OUT_CSV = FIG_DIR / "summary_4_3_tokenizer_fertility.csv"


def load_sample() -> pd.DataFrame:
    df = pd.read_csv(DATA_DIR / "Appendix_F_Sample.csv")
    df.columns = [c.strip() for c in df.columns]
    return df


def load_llm() -> pd.DataFrame:
    df = pd.read_csv(DATA_DIR / "LLM_Evaluation_Results.csv")
    df.columns = [c.strip() for c in df.columns]
    df["err"] = df["Overall Error %"].str.rstrip("%").astype(float) / 100
    df["sem_err"] = df["SEM Error %"].str.rstrip("%").astype(float) / 100
    return df


def fertility_metrics(df: pd.DataFrame) -> pd.DataFrame:
    df = df.dropna(subset=["Azerbaijani", "Turkish"]).copy()
    df["len_az"] = df["Azerbaijani"].str.len()
    df["len_tr"] = df["Turkish"].str.len()
    df["ratio"] = df["len_az"] / df["len_tr"]
    df["IFI"] = 1 / df["ratio"]
    return df


def main() -> None:
    sample = fertility_metrics(load_sample())
    llm = load_llm()

    summary = pd.DataFrame({
        "metric": [
            "n_items", "mean_len_az", "mean_len_tr", "mean_ratio (az/tr)",
            "mean_IFI", "sd_IFI", "mean_llm_overall_error",
            "mean_llm_sem_error",
        ],
        "value": [
            len(sample),
            sample["len_az"].mean(),
            sample["len_tr"].mean(),
            sample["ratio"].mean(),
            sample["IFI"].mean(),
            sample["IFI"].std(ddof=1),
            llm["err"].mean(),
            llm["sem_err"].mean(),
        ],
    })
    sample.to_csv(OUT_CSV.with_name("appendix_F_fertility_per_item.csv"), index=False)
    summary.to_csv(OUT_CSV, index=False)

    fig, axes = plt.subplots(1, 2, figsize=(11, 4.5))

    ax = axes[0]
    ax.bar(["Azerbaijani", "Turkish"],
           [sample["len_az"].mean(), sample["len_tr"].mean()],
           color=["#2c7fb8", "#f4a261"], edgecolor="black")
    for i, v in enumerate([sample["len_az"].mean(), sample["len_tr"].mean()]):
        ax.text(i, v + 0.05, f"{v:.2f}", ha="center", fontweight="bold")
    ax.set_ylabel("Mean word length (characters)")
    ax.set_title("Mean orthographic word length\n(Appendix F sample)")
    ax.spines[["top", "right"]].set_visible(False)

    ax = axes[1]
    ax.scatter(sample["IFI"], [1] * len(sample), s=90,
               c=np.arange(len(sample)), cmap="viridis", edgecolor="black")
    ax.axvline(1.0, color="red", ls="--", lw=1, label="parity (IFI = 1)")
    ax.set_yticks([])
    ax.set_xlabel("Inverse Fertility Index (len_tr / len_az)")
    ax.set_title(f"Per-item fertility asymmetry\n(mean IFI = {sample['IFI'].mean():.3f})")
    ax.legend(frameon=False)
    ax.spines[["top", "right", "left"]].set_visible(False)

    fig.suptitle("Figure 4.3 — Tokenizer fertility proxy: Azerbaijani vs Turkish",
                 fontweight="bold")
    fig.tight_layout(rect=[0, 0, 1, 0.93])
    fig.savefig(OUT_FIG, dpi=200)
    plt.close(fig)

    print(summary.to_string(index=False))
    print(f"Saved: {OUT_FIG}\nSaved: {OUT_CSV}")


if __name__ == "__main__":
    main()

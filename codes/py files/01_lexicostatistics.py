"""
ODB Project — Script 01: Lexicostatistical Exploration
======================================================
Loads the aggregate cognate, phonological-shift, and semantic-change tables
(Table 4.2, 4.3, 4.4) from /mnt/data/ODB_data_csvs/, performs exploratory
analysis of cognate classes (IDENT, COG-PHON, COG-SEM, REP, ...) and of
regular phonological and semantic shifts, computes summary metrics, and
produces a publication-quality figure saved to
    /mnt/data/figures/figure_4_1_lexicostatistics.png

Author: ODB project pipeline (Python port of 01_lexicostatistical_analysis.R)
"""
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

# --------------------------------------------------------------------------
# Paths
# --------------------------------------------------------------------------
DATA_DIR = Path("/mnt/data/ODB_data_csvs")
FIG_DIR = Path("/mnt/data/figures")
FIG_DIR.mkdir(parents=True, exist_ok=True)
OUT_FIG = FIG_DIR / "figure_4_1_lexicostatistics.png"
SUMMARY_CSV = FIG_DIR / "summary_4_1_lexicostatistics.csv"


def load_tables() -> dict:
    """Load the three aggregate tables required for the analysis."""
    tables = {
        "cognates": pd.read_csv(DATA_DIR / "Table_4_2_Cognates.csv"),
        "phonology": pd.read_csv(DATA_DIR / "Table_4_3_Phonology.csv"),
        "semantic": pd.read_csv(DATA_DIR / "Table_4_4_Semantic.csv"),
    }
    return tables


def analyse_cognates(df: pd.DataFrame) -> pd.DataFrame:
    """Exploratory summary of the cognate-class distribution."""
    df = df.copy()
    df["Percentage"] = pd.to_numeric(df["Percentage"], errors="coerce")
    df["Count"] = pd.to_numeric(df["Count"], errors="coerce")
    df = df.sort_values("Count", ascending=False).reset_index(drop=True)
    df["Cumulative %"] = df["Percentage"].cumsum()
    return df


def analyse_shifts(df: pd.DataFrame, count_col: str = "Count") -> pd.DataFrame:
    """Rank shift types (phonological or semantic) by frequency."""
    df = df.copy()
    df[count_col] = pd.to_numeric(df[count_col], errors="coerce")
    df = df.sort_values(count_col, ascending=False).reset_index(drop=True)
    df["Share %"] = 100.0 * df[count_col] / df[count_col].sum()
    df["Cumulative %"] = df["Share %"].cumsum()
    return df


def make_figure(cog: pd.DataFrame, pho: pd.DataFrame, sem: pd.DataFrame) -> None:
    """Three-panel publication figure: cognate classes, phonological shifts,
    semantic changes."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5.2))
    fig.suptitle("Figure 4.1 — Lexicostatistical profile of North Azerbaijani vs. Istanbul Turkish",
                 fontsize=13, fontweight="bold")

    # Panel A — cognate classes
    ax = axes[0]
    ax.barh(cog["Cognate type"][::-1], cog["Percentage"][::-1],
            color="#2b6f8c", edgecolor="black", linewidth=0.6)
    for i, (p, n) in enumerate(zip(cog["Percentage"][::-1], cog["Count"][::-1])):
        ax.text(p + 0.8, i, f"{p:.1f}% (n={int(n)})", va="center", fontsize=9)
    ax.set_xlabel("Share of lexical items (%)")
    ax.set_title("(a) Cognate classes", fontsize=11)
    ax.set_xlim(0, max(cog["Percentage"]) * 1.30)

    # Panel B — phonological shifts
    ax = axes[1]
    ax.barh(pho["Phonological shift"][::-1], pho["Count"][::-1],
            color="#b35806", edgecolor="black", linewidth=0.6)
    ax.set_xlabel("Number of lexical items")
    ax.set_title("(b) Regular phonological shifts", fontsize=11)

    # Panel C — semantic changes
    ax = axes[2]
    ax.barh(sem["Semantic change"][::-1], sem["Percentage"][::-1],
            color="#542788", edgecolor="black", linewidth=0.6)
    for i, p in enumerate(sem["Percentage"][::-1]):
        ax.text(p + 0.8, i, f"{p:.1f}%", va="center", fontsize=9)
    ax.set_xlabel("Share of lexical items (%)")
    ax.set_title("(c) Semantic change types", fontsize=11)
    ax.set_xlim(0, max(sem["Percentage"]) * 1.25)

    for ax in axes:
        ax.spines[["top", "right"]].set_visible(False)
        ax.tick_params(labelsize=9)

    fig.tight_layout(rect=[0, 0, 1, 0.94])
    fig.savefig(OUT_FIG, dpi=300, bbox_inches="tight")
    plt.close(fig)


def main() -> None:
    print("=" * 70)
    print("SCRIPT 01 — LEXICOSTATISTICAL EXPLORATION")
    print("=" * 70)

    tables = load_tables()
    cog = analyse_cognates(tables["cognates"])
    pho = analyse_shifts(tables["phonology"])
    sem = analyse_shifts(tables["semantic"])

    n_items = int(cog["Count"].sum())

    print(f"\nTotal lexical items analysed: {n_items}")
    print("\n-- Cognate classes (Table 4.2) --")
    print(cog.to_string(index=False))
    print("\n-- Regular phonological shifts (Table 4.3) --")
    print(pho.to_string(index=False))
    print("\n-- Semantic change types (Table 4.4) --")
    print(sem.to_string(index=False    print(sem.to_string(index=False))

    # Summary metrics
    retention = cog type"].isin(["IDENT", "COG-PHON"]), "Percentage"].sum()
    metrics = pd.DataFrame({
        "Metric": [
            "Total lexical items",
            "Retention (IDENT + COG-PHON, %)",
            "Replacement layer (REP + lost, %)",
            "Items with no semantic change (%)",
            "Most frequent phonological shift",
            "Number of distinct shift types",
        ],
        "Value": [
            n_items,
            round(retention, 2),
            round(cog.loc[~cog["Cognate type"].isin(["IDENT", "COG-PHON"]), "Percentage"].sum(), 2),
            round(sem.loc[sem["Semantic change"] == "none", "Percentage"].sum(), 2),
            f"{pho.iloc[0]['Phonological shift']} (n={int(pho.iloc[0]['Count'])})",
            len(pho),
        ],
    })
    print("\n-- Summary metrics --")
    print(metrics.to_string(index=False))

    summary = pd.concat([
        cog.assign(Table="4.2 Cognates").rename(columns={"Cognate type": "Category"}),
        pho.assign(Table="4.3 Phonology", Percentage=np.nan).rename(columns={"Phonological shift": "Category"}),
        sem.assign(Table="4.4 Semantic").rename(columns={"Semantic change": "Category"}),
    ], ignore_index=True)
    summary.to_csv(SUMMARY_CSV, index=False)

    make_figure(cog, pho, sem)
    print(f"\nFigure saved: {OUT_FIG}")
    print(f"Summary CSV saved: {SUMMARY_CSV}")
    print("SCRIPT 01 FINISHED — OK")


if __name__ == "__main__":
    main()

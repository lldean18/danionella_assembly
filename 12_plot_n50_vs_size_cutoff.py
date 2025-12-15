#!/usr/bin/env python3
import argparse
import sys
from pathlib import Path
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker


def parse_fasta_lengths(path):
    lengths = []
    with open(path, 'r') as fh:
        cur = 0
        for line in fh:
            if line.startswith(">"):
                if cur > 0:
                    lengths.append(cur)
                cur = 0
            else:
                cur += len(line.strip())
        if cur > 0:
            lengths.append(cur)
    return lengths


def compute_n50(lengths):
    if not lengths:
        return 0
    sorted_lens = sorted(lengths, reverse=True)
    total = sum(sorted_lens)
    half = total / 2
    running = 0
    for L in sorted_lens:
        running += L
        if running >= half:
            return L
    return 0


def geometric_cutoffs(start, end, n):
    if n == 1:
        return [start]
    vals = []
    for i in range(n):
        frac = i / (n - 1)
        v = start * (end / start) ** frac
        vals.append(int(round(v)))
    return sorted(set(vals))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("assembly")
    parser.add_argument("-o", "--output", default="n50_vs_cutoff.png")
    parser.add_argument("--csv", default="n50_vs_cutoff.csv")
    parser.add_argument("--start", type=int, default=10_000)
    parser.add_argument("--end", type=int, default=1_000_000)
    parser.add_argument("--points", type=int, default=50)
    args = parser.parse_args()

    assembly = Path(args.assembly)
    if not assembly.exists():
        sys.exit("Error: assembly file not found.")

    lengths = parse_fasta_lengths(str(assembly))
    if not lengths:
        sys.exit("Error: no sequences found in FASTA.")

    # compute original full-assembly N50
    original_n50 = compute_n50(lengths)

    cutoffs = geometric_cutoffs(args.start, args.end, args.points)

    results = []
    for c in cutoffs:
        filtered = [L for L in lengths if L >= c]
        n50 = compute_n50(filtered)
        results.append((c, n50, len(filtered)))

    # write CSV
    import csv
    with open(args.csv, "w", newline="") as fh:
        w = csv.writer(fh)
        w.writerow(["cutoff_bp", "N50_bp", "N50_Mbp", "num_contigs_remaining"])
        for c, n50, n in results:
            w.writerow([c, n50, n50 / 1e6, n])

    # extract values for plotting
    xs = [c for c, _, _ in results]
    ys_mbp = [n50 / 1e6 for _, n50, _ in results]
    contigs = [n for _, _, n in results]

    # plot
    import matplotlib.pyplot as plt
    fig, ax1 = plt.subplots(figsize=(9, 5))

    # force plain integers on x axis (no scientific notation)
    ax1.xaxis.set_major_formatter(ticker.FuncFormatter(lambda x, pos: f"{int(x):,}"))


    # N50 line
    ax1.plot(xs, ys_mbp, marker="o", color="tab:blue", label="N50 (after cutoff)")
    ax1.set_xlabel("Contig size cutoff (bp)")
    ax1.set_ylabel("N50 (Mbp)", color="tab:blue")
    ax1.tick_params(axis='y', labelcolor="tab:blue")
    ax1.grid(True, linestyle=":", alpha=0.6)

    # original N50 horizontal line
    ax1.axhline(y=original_n50 / 1e6, color="tab:red", linestyle="--",
                label=f"Original N50 = {original_n50/1e6:.2f} Mbp")

    # secondary axis for number of contigs
    ax2 = ax1.twinx()
    ax2.plot(xs, contigs, marker="s", color="tab:green", label="Number of contigs ≥ cutoff")
    ax2.set_ylabel("Number of contigs ≥ cutoff", color="tab:green")
    ax2.tick_params(axis='y', labelcolor="tab:green")

    # combined legend
    lines = ax1.get_lines() + ax2.get_lines()
    labels = [l.get_label() for l in lines]
    ax1.legend(lines, labels, loc="best")

    plt.title(f"N50 vs cutoff (and contig count) for {assembly.name}")
    fig.tight_layout()
    plt.savefig(args.output, dpi=150)

    print(f"Wrote {args.output} and {args.csv}")


if __name__ == "__main__":
    main()

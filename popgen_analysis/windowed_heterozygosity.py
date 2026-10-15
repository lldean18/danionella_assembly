#!/usr/bin/env python3

import pysam
import sys

if len(sys.argv) != 5:
    sys.exit(
        f"Usage: {sys.argv[0]} <vcf.gz> <sample_name> <window_size> <output.tsv>"
    )

vcf_file = sys.argv[1]
sample = sys.argv[2]
window = int(sys.argv[3])
outfile = sys.argv[4]

vcf = pysam.VariantFile(vcf_file)

counts = {}

for rec in vcf.fetch():

    # Skip non-biallelic variants
    if len(rec.alts) != 1:
        continue

    gt = rec.samples[sample]["GT"]

    # Skip missing genotypes
    if gt is None or None in gt:
        continue

    # Sort so 1/0 == 0/1
    gt = tuple(sorted(gt))

    chrom = rec.chrom
    win = (rec.pos - 1) // window

    key = (chrom, win)

    if key not in counts:
        counts[key] = [0, 0]      # heterozygous count, total sites

    counts[key][1] += 1

    if gt == (0, 1):
        counts[key][0] += 1

with open(outfile, "w") as out:

    out.write("Chromosome\tStart\tEnd\tHeterozygous\tSites\tHeterozygosity\n")

    for (chrom, win) in sorted(counts):

        het, total = counts[(chrom, win)]

        start = win * window + 1
        end = start + window - 1

        h = het / total if total > 0 else 0

        out.write(
            f"{chrom}\t{start}\t{end}\t{het}\t{total}\t{h:.6f}\n"
        )

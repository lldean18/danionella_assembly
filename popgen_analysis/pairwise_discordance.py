#!/usr/bin/env python3

import pysam
import sys

vcf = pysam.VariantFile(sys.argv[1])

sample1 = sys.argv[2]
sample2 = sys.argv[3]

window = int(sys.argv[4])

print("Chromosome\tStart\tEnd\tDifferences\tSites\tDiscordance")

counts = {}

for rec in vcf.fetch():

    if len(rec.alts) != 1:
        continue

    gt1 = rec.samples[sample1]["GT"]
    gt2 = rec.samples[sample2]["GT"]

    if None in gt1 or None in gt2:
        continue

    chrom = rec.chrom
    win = (rec.pos - 1) // window

    key = (chrom, win)

    if key not in counts:
        counts[key] = [0, 0]

    counts[key][1] += 1

    if tuple(sorted(gt1)) != tuple(sorted(gt2)):
        counts[key][0] += 1

for (chrom, win), (diff, total) in sorted(counts.items()):

    start = win * window + 1
    end = start + window - 1

    discordance = diff / total if total else 0

    print(f"{chrom}\t{start}\t{end}\t{diff}\t{total}\t{discordance:.6f}")

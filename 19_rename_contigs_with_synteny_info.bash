#!/bin/bash
# Laura Dean
# 9/1/26
# code used to rename the contigs in danionella assembly so that information
# about synteny to zebrafish chromosomes is included

new_headers=/gpfs01/home/mbzlld/github/danionella_assembly/

awk '
BEGIN { FS=OFS="\t" }

# Read mapping file first
FNR==NR {
    map[$1]=$0
    next
}

# Process FASTA
/^>/ {
    h=substr($0,2)
    if (h in map)
        print ">" map[h]
    else
        print $0
    next
}

# Print sequence lines unchanged
{ print }
' mapping.txt seqs.fa > seqs.renamed.fa


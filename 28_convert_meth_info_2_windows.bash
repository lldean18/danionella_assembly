#!/bin/bash
# 17/4/26

# code used to convert the methylation info to 5kb windows

# setup env
cd /gpfs01/home/mbzlld/data/danionella/fish_B/methylation

# filter out rows from the bedmethyl table with <10 valid reads
awk '$10>10' fish_A_simp_meth_0.85.bed > fish_A_simp_meth_0.85_DP10.bed
awk '$10>10' fish_A_simp_meth_0.85_comb.bed > fish_A_simp_meth_0.85_comb_DP10.bed
awk '$10>10' fish_A_simp_meth_0.85_2comb.bed > fish_A_simp_meth_0.85_2comb_DP10.bed

# extract C not hydroxy only
awk '$4=="m"' fish_A_simp_meth_0.85_comb_DP10.bed > fish_A_simp_meth_0.85_comb_DP10_5mC.bed

# make windows
bedtools makewindows -g /share/deepseq/shenson/ds1664_Wilkinson/03_medaka/consensus.fasta.fai -w 5000 > 5kb.windows.bed
bedtools makewindows -g /share/deepseq/shenson/ds1664_Wilkinson/03_medaka/consensus.fasta.fai -w 10000 > 10kb.windows.bed
bedtools makewindows -g /share/deepseq/shenson/ds1664_Wilkinson/03_medaka/consensus.fasta.fai -w 100000 > 100kb.windows.bed

# calculate number of CpG sites
bedtools coverage \
  -a 50kb.windows.bed \
  -b fish_A_simp_meth_0.85_2comb_DP10.bed \
  -counts > CpG_counts_50kb.bed

# calculate mean methylation
bedtools map \
  -a 50kb.windows.bed \
  -b fish_A_simp_meth_0.85_2comb_DP10.bed \
  -c 11 \
  -o mean \
  > fish_A_simp_meth_0.85_2comb_DP10.bed__mean_50kb.txt

######################################################
######################################################

# convert percent to counts
awk 'BEGIN{OFS="\t"} {print $0, $10*$11/100}' \
fish_A_simp_meth_0.85_comb_DP10.bed \
> meth_with_counts.bed

# resummarise
bedtools map \
  -a 10kb.windows.bed \
  -b meth_with_counts.bed \
  -c 10,19 \
  -o sum,sum \
  > window_cov_and_methcounts.txt

# compute weighted methylation
awk 'BEGIN{OFS="\t"}
{
if($4>0)
print $1,$2,$3,$5/$4*100;
else
print $1,$2,$3,"NA"
}' window_cov_and_methcounts.txt \
> fish_A_weighted_10kb_methylation.bed


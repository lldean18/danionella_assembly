#!/bin/bash
# Laura Dean
# 15/10/26

# run in Tmux window with srun

# setup env
mkdir -p /gpfs01/home/mbzlld/data/danionella/popgen/windowed_divergence
cd /gpfs01/home/mbzlld/data/danionella/popgen/windowed_divergence

##  # first run
##  reference=/share/deepseq/shenson/ds1664_Wilkinson/03_medaka/consensus.fasta
##  vcf=/gpfs01/home/mbzlld/data/danionella/popgen/variants/danionella_all_reads_Q30_DP10_GQ20_SNP_mis0.9.vcf.gz

# second run with final reference
reference=/gpfs01/home/mbzlld/data/danionella/fish_c/fishC_polished_nuclear_curated_no_ptg000061l.fa
vcf=/gpfs01/home/mbzlld/data/danionella/popgen/variants/all_fish_merged_nomissing.vcf.gz

conda activate samtools1.22
samtools faidx $reference
cut -f1,2 $reference.fai > genome.txt

# make windows
bedtools makewindows \
    -g genome.txt \
    -w 100000 > windows_100kb.bed

# calculate differences for each pair
python ~/github/danionella_assembly/popgen_analysis/pairwise_discordance.py \
$vcf FishA_ALL_simplex FishB_ALL_simplex 100000 > FishA_vs_FishB.tsv

python ~/github/danionella_assembly/popgen_analysis/pairwise_discordance.py \
$vcf FishA_ALL_simplex SUP_fish_c 100000 > FishA_vs_FishC.tsv

python ~/github/danionella_assembly/popgen_analysis/pairwise_discordance.py \
$vcf FishA_ALL_simplex fish_d 100000 > FishA_vs_FishD.tsv

python ~/github/danionella_assembly/popgen_analysis/pairwise_discordance.py \
$vcf FishB_ALL_simplex SUP_fish_c 100000 > FishB_vs_FishC.tsv

python ~/github/danionella_assembly/popgen_analysis/pairwise_discordance.py \
$vcf FishB_ALL_simplex fish_d 100000 > FishB_vs_FishD.tsv

python ~/github/danionella_assembly/popgen_analysis/pairwise_discordance.py \
$vcf SUP_fish_c fish_d 100000 > FishC_vs_FishD.tsv


# calculate the windowed heterozygosity
python ~/github/danionella_assembly/popgen_analysis/windowed_heterozygosity.py $vcf FishA_ALL_simplex 100000 FishA_100kb.tsv
python ~/github/danionella_assembly/popgen_analysis/windowed_heterozygosity.py $vcf FishB_ALL_simplex 100000 FishB_100kb.tsv
python ~/github/danionella_assembly/popgen_analysis/windowed_heterozygosity.py $vcf SUP_fish_c 100000 FishC_100kb.tsv
python ~/github/danionella_assembly/popgen_analysis/windowed_heterozygosity.py $vcf fish_d 100000 FishD_100kb.tsv




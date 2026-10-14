#!/bin/bash
# Laura Dean
# 13/10/26

# script to merge and filter variants called from ONT and illumina data

# start a session on a compute node
srun --partition defq --cpus-per-task 2 --mem 20g --time 04:00:00 --pty bash

# setup env
source $HOME/.bash_profile
module load bcftools-uoneasy/1.19-GCC-13.2.0
module load vcftools-uoneasy/0.1.16-GCC-12.3.0

# filter the fish D variants to contain only biallelic SNPs
bcftools view -v snps -m2 -M2 /gpfs01/home/mbzlld/data/danionella/fish_d/variants/curated_vs_fish_d_reads_flt.vcf.gz \
 -Oz --threads 16 -o /gpfs01/home/mbzlld/data/danionella/fish_d/variants/curated_vs_fish_d_reads_flt_snps.vcf.gz

# index the file
bcftools index -t /gpfs01/home/mbzlld/data/danionella/fish_d/variants/curated_vs_fish_d_reads_flt_snps.vcf.gz
bcftools index -t /gpfs01/home/mbzlld/data/danionella/popgen/variants/danionella_all_reads_Q30_DP10_GQ20.vcf.gz

# merge variant files
bcftools merge \
/gpfs01/home/mbzlld/data/danionella/popgen/variants/danionella_all_reads_Q30_DP10_GQ20.vcf.gz \
/gpfs01/home/mbzlld/data/danionella/fish_d/variants/curated_vs_fish_d_reads_flt_snps.vcf.gz \
-Oz -o /gpfs01/home/mbzlld/data/danionella/popgen/variants/all_fish_merged.vcf.gz

# filter merged file to remove all sites with missing data
vcftools --gzvcf /gpfs01/home/mbzlld/data/danionella/popgen/variants/all_fish_merged.vcf.gz --max-missing 1 --recode --stdout |
bgzip > /gpfs01/home/mbzlld/data/danionella/popgen/variants/all_fish_merged_nomissing.vcf.gz



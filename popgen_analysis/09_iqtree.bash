#!/bin/bash
# 29/7/26

# script to plot tree

#SBATCH --job-name=iqtree
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=15g
#SBATCH --time=6:00:00
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out


source $HOME/.bash_profile
conda activate iqtree
mkdir -p /gpfs01/home/mbzlld/data/danionella/popgen/iqtree
cd /gpfs01/home/mbzlld/data/danionella/popgen/iqtree
vcf=/gpfs01/home/mbzlld/data/danionella/popgen/variants/danionella_all_reads_Q30_DP10_GQ20_SNP_mis0.9.vcf.gz

iqtree \
    -s filtered.vcf.gz \
    --vcf \
    -m GTR+ASC \
    -bb 1000 \
    -nt AUTO



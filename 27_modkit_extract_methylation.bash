#!/bin/bash
# 17/4/26

# script to extract methylation information from dorado bams 

#SBATCH --job-name=extract_meth_info
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=50g
#SBATCH --time=20:00:00
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out


# setup env
source $HOME/.bash_profile
conda activate modkit
mkdir -p /gpfs01/home/mbzlld/data/danionella/fish_A/methylation
cd /gpfs01/home/mbzlld/data/danionella/fish_A/methylation


# extract methylation information from aligned reads
modkit pileup \
  /gpfs01/home/mbzlld/data/danionella/basecalls_methylation_CpG/fish_A/fish_A_simplex_SUP.bam \
  fish_A_simp_meth_0.85.bed \
  --log-filepath fish_A_simp_0.85_modkit.log \
  --reference /share/deepseq/shenson/ds1664_Wilkinson/03_medaka/consensus.fasta \
  --threads 8 \
  --cpg \
  --modified-bases 5mC 5hmC \
  --filter-threashold 0.85


conda deactivate


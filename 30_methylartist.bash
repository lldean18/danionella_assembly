#!/bin/bash
# 22/4/26

# code for methylartist plots

#SBATCH --job-name=methylartist
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=25g
#SBATCH --time=10:00:00
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out

# setup env
source $HOME/.bash_profile
#conda create -n methylartist -c bioconda methylartist
conda activate methylartist
mkdir -p /gpfs01/home/mbzlld/data/danionella/fish_B/methylation/methylartist
cd /gpfs01/home/mbzlld/data/danionella/fish_B/methylation/methylartist

# # make a plot of the hox genes
# methylartist locus \
# --bams /gpfs01/home/mbzlld/data/danionella/basecalls_methylation_CpG/fish_B/fish_B_simplex_SUP.bam \
# --interval ptg000006l:4690000-4830000 \
# --gtf /gpfs01/home/mbzlld/data/danionella/braker_sorted_fix.gtf.gz \
# --ref /share/deepseq/shenson/ds1664_Wilkinson/03_medaka/consensus.fasta \
# --motif CG \
# --labelgenes \
# --highlight 4707900-4710104,4711028-4713088,4714103-4715654,4732395-4734240,4737914-4739791,4759332-4760837,4771319-4772536,4774530-4775936,4782447-4789604,4795517-4798605,4804187-4806854,4820982-4822198,4829332-4830950 \
# --outfile danionella_hox_region_highlight

# try with region instead
methylartist region \
--bams /gpfs01/home/mbzlld/data/danionella/basecalls_methylation_CpG/fish_B/fish_B_simplex_SUP.bam \
--interval ptg000006l:4690000-4830000 \
--gtf /gpfs01/home/mbzlld/data/danionella/braker_sorted_fix.gtf.gz \
--ref /share/deepseq/shenson/ds1664_Wilkinson/03_medaka/consensus.fasta \
--motif CG \
--labelgenes \
--outfile danionella_hox_region4

conda deactivate



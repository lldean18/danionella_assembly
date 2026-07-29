#!/bin/bash
# 29/7/26

# script to calculate observed heterozygosity

#SBATCH --job-name=OH
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=50g
#SBATCH --time=24:00:00
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out


source $HOME/.bash_profile
conda activate angsd
mkdir -p /gpfs01/home/mbzlld/data/danionella/popgen/angsd
cd /gpfs01/home/mbzlld/data/danionella/popgen/angsd
reference=/share/deepseq/shenson/ds1664_Wilkinson/03_medaka/consensus.fasta

echo "/gpfs01/home/mbzlld/data/danionella/popgen/downsampling/FishA_ALL_simplex_TO_consensus_flt.bam" > bamlist.txt

angsd \
    -bam bamlist.txt \
    -ref $reference \
    -out FishA \
    -GL 2 \
    -doSaf 1 \
    -anc $reference \
    -minMapQ 30 \
    -minQ 20 \
    -uniqueOnly 0 \
    -remove_bads 1 \
    -only_proper_pairs 0 \
    -baq 1 \
    -C 50 \
    -nThreads 16







